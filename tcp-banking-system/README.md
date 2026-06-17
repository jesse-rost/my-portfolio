# Producer-Consumer Banking Server

A concurrent TCP banking system implemented in C that enables multiple clients to safely access and modify shared bank accounts in real time. The project combines socket programming, POSIX threads, semaphores, mutexes, and Linux epoll to demonstrate scalable client-server communication and synchronized transaction processing.

The system utilizes a producer-consumer architecture in which client requests are placed into a bounded transaction queue and processed by worker threads. This design ensures account consistency during concurrent access while maintaining efficient network responsiveness and persistent transaction storage.

---

# Overview

The application consists of a multithreaded TCP server and multiple client applications communicating over standard TCP sockets.

Each connected client submits banking operations such as deposits, withdrawals, and balance inquiries. Requests are placed into a shared transaction queue where worker threads safely process transactions and update account balances.

By separating network communication from transaction execution, the system achieves improved scalability, responsiveness, and thread-safe access to shared account data.

---

# Key Features

- Multi-client TCP server architecture
- Producer-consumer transaction processing
- POSIX thread-based concurrency
- Bounded shared transaction queue
- Semaphore-controlled queue management
- Mutex-protected shared resources
- Epoll-based connection handling
- Persistent account storage
- Transaction logging
- Graceful server shutdown

---

# System Architecture

```text
        Clients
           │
           ▼
    Producer Threads
           │
           ▼
┌──────────────────────┐
│ Transaction Queue    │
│ (Bounded Buffer)     │
└──────────┬───────────┘
           │
           ▼
    Consumer Threads
           │
           ▼
    Account Database
     (balance.csv)
```

Each connected client is serviced by a dedicated producer thread responsible for receiving and validating requests.

Validated transactions are inserted into a shared bounded queue where consumer threads safely process banking operations and update account records.

---

# Technical Highlights

## Producer-Consumer Architecture

The banking system follows a classic producer-consumer design pattern.

### Producers

Producer threads:

- Receive client requests
- Parse banking commands
- Validate transaction parameters
- Insert work into the shared queue

### Consumers

Consumer threads:

- Remove transactions from the queue
- Update account balances
- Write transaction logs
- Return results to the requesting client

Separating network communication from transaction execution improves scalability while maintaining clear responsibility boundaries within the system.

---

## Thread Synchronization

Concurrent access to shared resources is protected through a combination of semaphores and mutexes.

### Semaphores

Semaphores are used to:

- Track available queue capacity
- Track pending transactions
- Coordinate producer and consumer execution

### Mutexes

Mutexes protect:

- Transaction queue operations
- Account balance updates
- Transaction log writes

These synchronization mechanisms prevent race conditions when multiple clients access the same account simultaneously.

---

## Epoll-Based Networking

The server utilizes Linux's epoll API to efficiently monitor file descriptor activity.

The event loop handles:

- Incoming client connections
- Ready socket events
- Server console input for shutdown commands

Using epoll allows the server to remain responsive without continuously polling sockets and scales more efficiently than traditional `select()` or `poll()` approaches.

---

## Persistent Storage

Account balances are maintained using:

```text
balance.csv
```

Transaction history is recorded in:

```text
server_log.txt
```

This provides persistence across server restarts while also creating an auditable transaction history for debugging and verification.

---

# Verification & Testing

System functionality was validated using multiple concurrent clients performing operations against shared accounts.

## Functional Testing

Verified support for:

- Deposits
- Withdrawals
- Balance inquiries
- Invalid command handling
- Invalid decimal precision rejection
- Negative transaction rejection

### Example Client Session

![Banking System Demo](docs/example_usage_run.png)

*A sample client session demonstrating successful deposits, withdrawals, balance inquiries, and server-side validation of invalid transaction requests.*

---

## Concurrency Validation

Multiple clients simultaneously accessed identical account records while verifying:

- Correct account balances
- Proper transaction ordering
- Absence of race conditions
- Stable queue operation

Consumer threads correctly serialized account updates while allowing multiple client connections to remain active concurrently.

---

# Repository Structure

```text
producer-consumer-banking-server/
├── Client.c
├── Server.c
├── Makefile
├── balance.csv
├── server_log.txt
├── example_usage_run.png
└── README.md
```

---

# Build & Run

## Build

```bash
make
```

## Start Server

```bash
./Server
```

## Start Client

```bash
./Client
```

### Supported Commands

```text
deposit <amount>
withdraw <amount>
balance
exit
```

---

# Key Concepts Demonstrated

- TCP/IP socket programming
- Client-server architecture
- Producer-consumer design patterns
- POSIX threads
- Semaphores and mutexes
- Concurrent resource protection
- Linux epoll event handling
- Persistent file management
- Systems programming in C

---

# Author

**Jesse Rost**  
**Hunter Carroll**

**Course:** CPE 2600 – Systems Programming
