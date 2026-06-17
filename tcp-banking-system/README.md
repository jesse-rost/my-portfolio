# Producer-Consumer Banking Server

A multithreaded TCP banking system implemented in C that allows multiple clients to concurrently access and modify shared bank accounts. The project demonstrates socket programming, producer-consumer synchronization, POSIX threads, semaphores, mutexes, and Linux epoll-based event handling.

Developed as part of CPE 2600 (Systems Programming), the server safely processes deposits, withdrawals, and balance inquiries while maintaining account consistency across multiple simultaneous client connections.

---

# Overview

The system consists of a TCP server and multiple client applications.

Each connected client communicates with the server through a dedicated producer thread. Banking requests are placed into a shared bounded transaction queue, where consumer threads process requests and update account balances.

This design separates network communication from transaction processing while ensuring thread-safe access to shared resources.

---

# Key Features

- Multi-client TCP server
- Producer-consumer transaction processing model
- Bounded shared transaction queue
- POSIX thread-based concurrency
- Semaphore-controlled queue management
- Mutex-protected shared resources
- Epoll-based connection handling
- Persistent account storage using CSV files
- Transaction logging for auditing and debugging
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

---

# Synchronization Strategy

The project uses a classic producer-consumer design pattern.

### Producers

Each connected client is serviced by a dedicated thread that:

- Receives banking commands
- Validates requests
- Places transactions into the shared queue

### Consumers

A pool of consumer threads removes transactions from the queue and:

- Updates account balances
- Writes transaction logs
- Returns results to the requesting client

### Thread Safety

Synchronization is enforced through:

- Semaphores
  - Track available queue slots
  - Track pending transactions

- Mutexes
  - Protect queue operations
  - Protect account balance updates
  - Protect transaction logging

This prevents race conditions when multiple clients access the same account simultaneously.

---

# Networking Design

The server communicates using TCP sockets.

Linux epoll is used to efficiently monitor:

- Incoming connection requests
- Server console input for shutdown commands

Using epoll allows the server to remain responsive without continuously polling file descriptors.

---

# Data Persistence

Account information is stored in:

```text
balance.csv
```

Transaction history is written to:

```text
server_log.txt
```

This allows account balances and transaction records to persist across server restarts.

---

# Usage

## Start the Server

```bash
./Server
```

## Start a Client

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

### Example Session

```text
Enter account number: 1001

deposit 50.00
Server response: Deposit successful. New balance: 150.00

withdraw 20.00
Server response: Withdrawal successful. New balance: 130.00

balance
Server response: Current balance: 130.00
```

---

# Concepts Demonstrated

- TCP/IP socket programming
- Client-server architecture
- Producer-consumer synchronization
- POSIX threads
- Semaphores and mutexes
- Concurrent data access protection
- Linux epoll event handling
- File-based persistence
- Systems programming in C

---

# Author

**Jesse Rost**  
**Hunter Carroll**

**Course:** CPE 2600 – Systems Programming
