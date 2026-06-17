CC = gcc
CFLAGS = -Wall -g
LDFLAGS = 

# Client executable
CLIENT_SOURCES = src/Client.c
CLIENT_OBJECTS = $(CLIENT_SOURCES:.c=.o)
CLIENT_EXECUTABLE = Client

# Server executable
SERVER_SOURCES = src/Server.c
SERVER_OBJECTS = $(SERVER_SOURCES:.c=.o)
SERVER_EXECUTABLE = Server

all: $(CLIENT_EXECUTABLE) $(SERVER_EXECUTABLE)

# Build Client executable
$(CLIENT_EXECUTABLE): $(CLIENT_OBJECTS)
	$(CC) $(CLIENT_OBJECTS) $(LDFLAGS) -o $@

# Build Server executable
$(SERVER_EXECUTABLE): $(SERVER_OBJECTS)
	$(CC) $(SERVER_OBJECTS) $(LDFLAGS) -o $@

# Pattern rule to compile source files to object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(CLIENT_OBJECTS) $(SERVER_OBJECTS) $(CLIENT_EXECUTABLE) $(SERVER_EXECUTABLE)
