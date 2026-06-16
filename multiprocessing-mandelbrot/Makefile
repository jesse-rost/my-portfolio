CC=gcc
CFLAGS=-Wall -g
LDFLAGS=-ljpeg

# Executables
EXEC_MANDEL=mandel
EXEC_MOVIE=mandelmovie

# Source files
MANDEL_SRC=mandel.c jpegrw.c
MOVIE_SRC=mandelmovie.c

# Object files
MANDEL_OBJ=$(MANDEL_SRC:.c=.o)
MOVIE_OBJ=$(MOVIE_SRC:.c=.o)

# Default target: build both programs
all: $(EXEC_MANDEL) $(EXEC_MOVIE)

# Build mandel
$(EXEC_MANDEL): $(MANDEL_OBJ)
	$(CC) $(MANDEL_OBJ) $(LDFLAGS) -o $(EXEC_MANDEL)

# Build mandelmovie
$(EXEC_MOVIE): $(MOVIE_OBJ)
	$(CC) $(MOVIE_OBJ) $(LDFLAGS) -o $(EXEC_MOVIE)

# Pattern rule for .o + dependency files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
	$(CC) -MM $< > $*.d

# Include dependency files if they exist
-include $(MANDEL_OBJ:.o=.d)
-include $(MOVIE_OBJ:.o=.d)

# Clean target
clean:
	rm -f $(MANDEL_OBJ) $(MOVIE_OBJ) $(EXEC_MANDEL) $(EXEC_MOVIE) *.d
