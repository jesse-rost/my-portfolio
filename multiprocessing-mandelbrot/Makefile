CC = gcc
CFLAGS = -Wall -Iinclude
LDFLAGS = -lpthread -ljpeg

# Source and Object files
SOURCES = src/mandel.c src/mandelmovie.c src/jpegwr.c
OBJECTS = $(SOURCES:.c=.o)
EXECUTABLE = mandel

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

# Pattern rule to compile source files to object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)
```
eof

### 3. Finalize and Push
After updating the `Makefile`, stage it and push your clean project structure to GitHub:

```bash
# Add the updated Makefile
git add Makefile
git commit -m "Build: Update Makefile for new directory structure"

# Pull to resolve any remote conflicts, then push
git pull origin main --rebase
git -c credential.helper= push origin main
