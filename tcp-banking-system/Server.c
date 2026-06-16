/*************************************************************************
*  @file        : Server.c
*  @brief       : Basic TCP comms for banking on server side
*  This server allows for multiple clients to connect and perform
*  transactions on a shared account.
*  
*  Name         : hcarroll@msoe.edu <Hunter Carroll>
*                 rostj@msoe.edu <Jesse Rost>
*  Course       : CPE 2600
*  Section      : 012
*  Assignment   : Lab 15
*  Date         : 12/9/2025
*
*  Algorithm:
*  - Initialize semaphors for buffering
*  - Initialize mutexes for balance file and log file
*  - Initialize epoll for event handling
*  - Create consumer threads
*  - Create producer threads
*  - Accept new connections and spawn producer threads
*  - Process transactions
*
*  Compile: make
*  Note: ./Server
*  Note: Make sure to create balance.csv and server_log.txt in same
*  directory as Server executable before running.
*  Note: Type 'exit' to shutdown the server.
*************************************************************************/  
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <time.h>
#include <pthread.h>
#include <semaphore.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <errno.h>

// define some constants
#define MAX 256
#define SERVER_HOST "localhost"
#define SERVER_IP "172.20.10.2" //"127.0.0.1" $hostname -I
#define BUFLEN 256
#define SERVER_PORT 1234
#define BUFFER_SIZE 100 // size of trans buffer
#define NUM_CONSUMERS 4 // number of consumer threads

char line[BUFLEN];
struct sockaddr_in server_addr, client_addr;
int mysock, csock, r, n;
socklen_t len;

// Transaction structure
typedef struct {
    int account_num;
    char command[MAX];
    float amount;
    int csock;
    char response[MAX];
} transaction;

// Queue for transactions
transaction tx_buffer[BUFFER_SIZE];
int buffer_in = 0;
int buffer_out = 0;
sem_t empty_slots;
sem_t full_slots;
pthread_mutex_t buffer_mutex;
pthread_mutex_t balance_file_mutex;
pthread_mutex_t log_file_mutex;
int epoll_fd;
volatile int server_shutdown = 0;

/**
 * @brief Initialize the server socket
 * @return 0 on success
*/
int server_init();

/**
 * @brief Producer thread for processing transactions
 * @param arg Pointer to client socket
 * @return NULL
*/
void* producer_thread(void *arg);

/**
* @brief Consumer thread for processing transactions
* @param arg Pointer to transaction
* @return NULL
*/
void* consumer_thread(void *arg);

/**
 * @brief Process a transaction
 * @param txn pointer to transaction
 * @return 0 on success
*/
int process_transaction(transaction *txn);

/**
 * @brief Get balance from csv file
 * @param account_num account number
 * @return balance
 * @note: uses account number as key to get balance from balance.csv
*/
float get_balance_csv(int account_num);

/**
 * @brief Update balance to csv file
 * @param account_num account number 
 * @param balance balance of account
 * @return 0 on success
*/
int update_balance_csv(int account_num, float balance);

/** 
 * @brief log a transaction
 * @param account_num account number
 * @param command command (deposit, withdraw, balance, exit)
 * @param amount amount of transaction
 * @param balance balance of account after transaction
*/
int log_transaction(int account_num, char *command, float amount, float balance);

/**
 * @brief Main function for server side
 * @return 0 on succes
*/
int main (void)
{
    pthread_t consumer_threads[NUM_CONSUMERS];
    int i;
    const int MAX_EVENTS = 64;
    struct epoll_event ev, events[MAX_EVENTS];
    

    // initialize the semaphores for buffering
    sem_init(&empty_slots, 0, BUFFER_SIZE);
    sem_init(&full_slots, 0, 0);

    // initialize the mutexes
    pthread_mutex_init(&buffer_mutex, NULL);
    pthread_mutex_init(&balance_file_mutex, NULL);
    pthread_mutex_init(&log_file_mutex, NULL);

    // initalize server socket
    server_init();

    epoll_fd = epoll_create1(0);
    if (epoll_fd == -1) {
        perror("epoll_create1");
        exit(EXIT_FAILURE);
    }

    // add server socket to epoll
    ev.events = EPOLLIN;
    ev.data.fd = mysock;
    if(epoll_ctl(epoll_fd, EPOLL_CTL_ADD, mysock, &ev) == -1) {
        perror("epoll_create1");
        exit(EXIT_FAILURE);
    }

    // add standard in to epoll to monitor for "exiting"
    ev.events = EPOLLIN;
    ev.data.fd = STDIN_FILENO;
    if(epoll_ctl(epoll_fd, EPOLL_CTL_ADD, STDIN_FILENO, &ev) == -1) {
        perror("epoll_ctl: stdin");
        exit(EXIT_FAILURE);
    }


    // create consumer threads
    for (i = 0; i < NUM_CONSUMERS; i++) {
        pthread_create(&consumer_threads[i], NULL, consumer_thread, NULL);
    }
    printf("Consumer threads created\n");
    printf("Server ready, waiting for connections...\n");
    printf("Type 'exit' to shutdown the server\n");

    // main accept loop to spawn producer threads
    while(!server_shutdown) {
        int nfds = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
        if (nfds == -1) {
            perror("epoll_wait");
            continue;
        }

        for (int j = 0; j < nfds; j++) {
            // check if stdin has input to exit the program
            if(events[j].data.fd == STDIN_FILENO) {
                char input[MAX];
                if (fgets(input, MAX, stdin) != NULL) {
                    // Remove the newline character
                    input[strcspn(input, "\n")] = '\0';
                    if(!strcmp(input, "exit")) {
                        printf("Shutting down the server...\n");
                        server_shutdown = 1;
                        break;
                    }
                }
            }
            // Check if this is the server socket (new connection)
            else if (events[j].data.fd == mysock) {
                len = sizeof(client_addr);
                csock = accept(mysock, (struct sockaddr*)&client_addr, &len);
                if (csock < 0) {
                    perror("accept");
                    continue;
                }
                printf("server: new connection accepted from %s:%d\n", 
                       inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));

                // spawn producer thread for this client
                pthread_t producer_tid;
                int *csock_ptr = malloc(sizeof(int));
                if(csock_ptr == NULL) {
                    printf("server: malloc failed\n");
                    epoll_ctl(epoll_fd, EPOLL_CTL_DEL, csock, NULL);
                    close(csock);
                    continue;
                }
                *csock_ptr = csock;

                pthread_create(&producer_tid, NULL, producer_thread, csock_ptr);
                pthread_detach(producer_tid);
            }
        }
    }

    // Cleanup: shutdown server socket
    printf("Closing server...\n");
    close(mysock);
    close(epoll_fd);

    // Consumer threads cleanup
    printf("Waiting for consumer thread...\n");
    for (i = 0; i < NUM_CONSUMERS; i++) {
        pthread_cancel(consumer_threads[i]);
        pthread_join(consumer_threads[i], NULL);
    }

    // Cleanup: destroy semaphores and mutexes
    sem_destroy(&empty_slots);
    sem_destroy(&full_slots);
    pthread_mutex_destroy(&buffer_mutex);
    pthread_mutex_destroy(&balance_file_mutex);
    pthread_mutex_destroy(&log_file_mutex);

    printf("Server shutdown\n");
    return 0;
}

/**
 * @brief Initialize the server socket
 * @return 0 on success
*/
int server_init()
{
    printf("create stream socket\n");
    mysock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (mysock < 0) {
        printf("socket call failed\n");
    }

    // Set SO_REUSEADDR to allow binding to same port after a crash
    int opt = 1;
    if (setsockopt(mysock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        printf("setsockopt failed\n");
    }

    printf("fill server address with host IP and Port number\n");
    server_addr.sin_family = AF_INET;
    //inet_pton(AF_INET, SERVER_IP, &server_addr.sin_addr);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    server_addr.sin_port = htons(SERVER_PORT);
    printf("bind the socket");
    r = bind(mysock, (struct sockaddr*)&server_addr, sizeof(server_addr));
    if (r<0) {
        printf("bind failed\n");
    }
    printf("server is listening  ...\n");
    listen(mysock, 5); // queue length of 5
    printf("server init done\n");

    return 0;
}

/**
 * @brief Producer thread for processing transactions
 * @param arg Pointer to client socket
 * @return NULL
*/
void* producer_thread(void *arg) {
    int csock = *(int*)arg;
    free(arg); // free the memory for argument

    char account[MAX];
    char line[MAX];
    transaction txn;

    // read the account number from client
    bzero(account, MAX);
    int n = read(csock, account, MAX);
    if (n <= 0) {
        close(csock);
        return NULL;; // client disconnected
    }
    account[n] = '\0';
    int account_num = atoi(account);

    // read transaction and queue it
    while(1) {
        bzero(line, MAX);
        n = read(csock, line, MAX);
        if (n <= 0) {
            break;// client disconnected
        }

        line[n] = '\0';

        // prepare transaction
        txn.account_num = account_num;
        strncpy(txn.command, line, MAX);
        txn.csock = csock;

        // put transaction into buffer
        sem_wait(&empty_slots);
        pthread_mutex_lock(&buffer_mutex);

        tx_buffer[buffer_in] = txn;
        buffer_in = (buffer_in + 1) % BUFFER_SIZE;

        pthread_mutex_unlock(&buffer_mutex);
        sem_post(&full_slots);
    }

    close(csock);
    return NULL;
}

/**
 * @brief Consumer thread for processing transactions
 * @param arg Pointer to transaction
 * @return NULL
*/
void* consumer_thread(void *arg) {
    transaction txn;

    while(1) {
        // Get transaction from buffer
        sem_wait(&full_slots);
        pthread_mutex_lock(&buffer_mutex);

        txn = tx_buffer[buffer_out];
        buffer_out = (buffer_out + 1) % BUFFER_SIZE;

        pthread_mutex_unlock(&buffer_mutex);
        sem_post(&empty_slots);

        // process transaction
        process_transaction(&txn);
    }
    return NULL;
}

/**
 * @brief Process a transaction
 * @param txn pointer to transaction
 * @return 0 on success
*/
int process_transaction(transaction *txn) {
    char command[MAX];
    float amount = 0;
    float balance = 0;
    char new_line[MAX];

    // parse command
    strcpy(command, txn->command);
    char *token = strtok(command, " ");
    if (token == NULL) {
        return -1;
    }
    char *amount_str = strtok(NULL, " ");
    if(amount_str != NULL) {
        amount = atof(amount_str);
    }

    // Get current balance
    pthread_mutex_lock(&balance_file_mutex);
    balance = get_balance_csv(txn->account_num);

    // process the command transaction
    if(!strcmp(command, "deposit")) {
        if (amount < 0) {
            sprintf(new_line, "Invalid amount. Please enter a positive value.");
        } else if (amount * 100 - (float)((int)(amount * 100)) > 0.1) {
            sprintf(new_line, "Invalid amount. Please enter a value with only two decimal places.");
        } else {
            balance += amount;
            update_balance_csv(txn->account_num, balance);
            log_transaction(txn->account_num, "deposit", amount, balance);
            sprintf(new_line, "Deposit of $%.2f successful. New balance: $%.2f", amount, balance);
        }
    } else if(!strcmp(command, "withdraw")) {
        if (balance < amount) {
            sprintf(new_line, "Insufficient funds. Current balance: $%.2f", balance);
        } else if (amount * 100 - (float)((int)(amount * 100)) > 0.1) {
            sprintf(new_line, "Invalid amount. Please enter a value with only two decimal places.");
        } else {
            balance -= amount;
            update_balance_csv(txn->account_num, balance);
            log_transaction(txn->account_num, "withdraw", amount, balance);
            sprintf(new_line, "Withdrawal of $%.2f successful. New balance: $%.2f", amount, balance);
        }
    } else if (!strcmp(command, "balance")) {
        sprintf(new_line, "Current balance: $%.2f", balance);
    } else if (!strcmp(command, "exit")) {
        sprintf(new_line, "Exiting...");
        pthread_mutex_unlock(&balance_file_mutex);

        // send response before closing
        write(txn->csock, new_line, MAX);

        close(txn->csock);
        return 0;
    }

    pthread_mutex_unlock(&balance_file_mutex);

    // send response back to client
    write(txn->csock, new_line, MAX);
    return 0;
}

/**
 * @brief Get balance from csv file
 * @param account_num account number
 * @return balance
 * @note: uses account number as key to get balance from balance.csv
*/
float get_balance_csv(int account_num) {
    FILE *balance_file = fopen("balance.csv", "r");
    if (balance_file == NULL) {
        printf("Failed to open balance.csv\n");
        return 0.0;
    }
    // Using account number as key, get final balance for the account in balance.csv
    char balance_line[MAX];
    float balance = 0;
    char account_str[MAX];
    sprintf(account_str, "%d", account_num);

    while(fgets(balance_line, MAX, balance_file) != NULL) {
        char *acc_str = strtok(balance_line, ",");
        char line_copy[MAX];
        strncpy(line_copy, balance_line, MAX);
        line_copy[MAX - 1] = '\0';
        if (acc_str != NULL && strcmp(acc_str, account_str) == 0) {
            char *balance_str = strtok(NULL, ",");
            if (balance_str != NULL) {
                balance = atof(balance_str);
            }
        }
    }
    fclose(balance_file);
    return balance;
}

/**
 * @brief Update balance to csv file
 * @param account_num account number 
 * @param balance balance of account
 * @return 0 on success
*/
int update_balance_csv(int account_num, float balance) {
    FILE *balance_file = fopen("balance.csv", "a");
    if (balance_file == NULL) {
        printf("Failed to open balance.csv for writing\n");
        return 1;
    }
    fprintf(balance_file, "%d,%.2f\n", account_num, balance);
    fclose(balance_file);
    return 0;
}

/**
 * @brief Log a transaction
 * @param account_num account number
 * @param command command (deposit, withdraw, balance, exit)
 * @param amount amount of transaction
 * @param balance balance of account after transaction
 * @return 0 on success
*/
int log_transaction(int account_num, char *command, float amount, float balance) {
    pthread_mutex_lock(&log_file_mutex);
    FILE *log_file = fopen("server_log.txt", "a");
    if (log_file == NULL) {
        printf("Failed to open server_log.txt for writing\n");
        pthread_mutex_unlock(&log_file_mutex);
        return 1;
    }
    // Grab current time and date stamp
    time_t now = time(NULL);
    struct tm *timeinfo = localtime(&now);
    char timestamp[MAX];
    strftime(timestamp, MAX, "%a %b %d %H:%M:%S %Y", timeinfo);
    fprintf(log_file, "%s\n - Account: %d - %s of $%.2f successful. New balance: $%.2f\n", timestamp, account_num, command, amount, balance);
    fclose(log_file);
    pthread_mutex_unlock(&log_file_mutex);
    return 0;
}