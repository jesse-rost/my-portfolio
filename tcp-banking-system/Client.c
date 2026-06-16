/*************************************************************************
*  @file        : Client.c
*  @brief       : Basic TCP comms foro banking on client side
*  
*  Name         : hcarroll@msoe.edu <Hunter Carroll>
*                 rostj@msoe.edu <Jesse Rost>
*  Course       : CPE 2600
*  Section      : 012
*  Assignment   : Lab 15
*  Date         : 12/9/2025
*
*  Algorithm:
*  - Initialize socket
*  - Connect to server
*  - Read account number
*  - Send account number to server
*  - Read command from user
*  - Send command to server
*  - Read response from server
*  - Close socket
*
*  Compile: make
*  Note: ./Client
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
// define some constants
#define MAX 256
#define SERVER_HOST "localhost"
#define SERVER_IP "172.20.10.2" //"127.0.0.1" $hostname -I
#define BUFLEN 256
#define SERVER_PORT 1234

char line[BUFLEN];
struct sockaddr_in server_addr;
int sock, r;

/**
 * @brief Initialize the client socket
 * @return 0 on success
*/
int client_init();

/**
 * @brief Main function for client side
 * @return 0 on success
*/
int main (void)
{
    char line[MAX], ans[MAX];
    char account[MAX];
    client_init();
    
    // Read account number
    printf("Enter account number: ");
    bzero(account, MAX);
    if (fgets(account, MAX, stdin) == NULL) {
        printf("Error reading account number, exiting...");
        close(sock);
        return 1;
    }
    // Remove trailing newLine
    int account_len = strlen(account);
    account[account_len - 1] = '\0';

    // Send account number to server side
    write(sock, account, MAX);
    
    while (1) {
        printf("Enter command (withdraw <amount>, deposit <amount>, balance, exit): ");
        bzero(line, MAX);
        fgets(line, MAX, stdin);
        line[strlen(line)-1] = 0; //remove the \n

        // check for exit
        if(!strcmp(line, "exit")) {
            // Send exit command to server
            write(sock, line, MAX);
            break;
        }

        write(sock, line, MAX);
        read(sock, ans, MAX);
        printf("Server response: %s\n", ans);
    }
    close(sock);
}

/**
 * @brief Initialize the client socket
 * @return 0 on success
*/
int client_init()
{
    printf("create stream socket\n");
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock < 0) {
        printf("socket call failed\n");
    }
    printf("fill server address with host IP and Port number\n");
    server_addr.sin_family = AF_INET;
    inet_pton(AF_INET, SERVER_IP, &server_addr.sin_addr);
    //server_addr.sin_addr.s_addr = htonl(INADDR_ANY);//**********
    server_addr.sin_port = htons(SERVER_PORT);
    printf("connect to server");
    r = connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr));
    if (r<0) {
        printf("connect failed\n");
    }
    printf("connected ok  ...\n");
 
    printf("client init done\n");

    return 0;
}