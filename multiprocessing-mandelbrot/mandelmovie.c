/**
 * @file        : mandelmovie.c
 * @brief       : Generates a sequence of Mandelbrot frames using multiprocessing.
 *
 * Course       : CPE 2600
 * Section      : 112
 * Assignment   : Lab 12 - Multiprocessing
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 11/25/25
 *
 * Algorithm:
 * - Parse command-line options using getopt to configure:
 *      * number of children allowed (-n)
 *      * number of threads per image (-t)
 *      * x and y center coordinates
 *      * initial scale value
 * - For each frame (0 to FRAME_COUNT - 1):
 *      * Wait if current active child count >= allowed number.
 *      * Fork a new child process.
 *      * Child:
 * - Compute zoomed scale value.
 * - Build filename for output image.
 * - Convert all parameters (including thread count) to strings.
 * - Execute ./mandel via execl, passing the thread count for intra-process parallelism.
 * * Parent:
 * - Continue loop to spawn next frame (as allowed).
 * - After loop, parent waits for ALL remaining children using wait().
 * - Print completion message and exit.
 */

#include "mandelmovie.h"
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

// named constants

#define DEFAULT_CHILDREN 4
#define DEFAULT_SCALE 4.0
#define FRAME_COUNT 50
#define ZOOM_FACTOR 0.02

#define FILENAME_BUF 64
#define COORD_BUF 32

// function prototypes

static void generate_frame(int frame_index,
                           double xcenter,
                           double ycenter,
                           double initial_scale,
                           int num_threads);

// function implementations

/**
 * @brief Generates a single Mandelbrot frame by forking and calling exec().
 *
 * @param frame_index  Index of the frame (0–49)
 * @param xcenter      X coordinate of the Mandelbrot center
 * @param ycenter      Y coordinate of the Mandelbrot center
 * @param initial_scale    Initial zoom scale for frame 0
 * @param num_threads  Number of threads for mandel to use
 */
static void generate_frame(int frame_index,
                           double xcenter,
                           double ycenter,
                           double initial_scale,
                           int num_threads) {
    double frame_scale = initial_scale *
                          (1.0 - (frame_index * ZOOM_FACTOR));

    char filename[FILENAME_BUF];
    sprintf(filename, "frame_%02d.jpg", frame_index);

    char x_str[COORD_BUF];
    char y_str[COORD_BUF];
    char s_str[COORD_BUF];
    char t_str[COORD_BUF];

    sprintf(x_str, "%.6f", xcenter);
    sprintf(y_str, "%.6f", ycenter);
    sprintf(s_str, "%.6f", frame_scale);
    sprintf(t_str, "%d", num_threads);

    printf("[Child %d] Generating %s at scale %.6f with %d threads\n",
           getpid(), filename, frame_scale, num_threads);

    execl("./mandel", "mandel",
           "-x", x_str,
           "-y", y_str,
           "-s", s_str,
           "-o", filename,
           "-t", t_str,
           (char *)NULL);

    perror("execl failed");
    exit(1);
}

/**
 * @brief Prints help/usage information for the mandelmovie program.
 */
void show_help(void) {
    printf("Use: mandelmovie [options]\n");
    printf("Where options are:\n");
    printf("  -n <max>    Max number of concurrent children "
           "(default = %d)\n", DEFAULT_CHILDREN);
    printf("  -t <max>    Max number of threads per image (1-20, default=1)\n");
    printf("  -x <coord>  X coordinate of Mandelbrot center (default 0)\n");
    printf("  -y <coord>  Y coordinate of Mandelbrot center (default 0)\n");
    printf("  -s <scale>  Initial zoom scale (default %.1f)\n",
           DEFAULT_SCALE);
    printf("  -h          Show this help text\n\n");
    printf("Generates %d images named frame_00.jpg ... frame_49.jpg.\n",
           FRAME_COUNT);
}


/**
 * @brief Program entry point. Generates a 50-frame Mandelbrot zoom movie
 *        using multiprocessing.
 *
 * @param argc  Number of command-line arguments.
 * @param argv  Array of argument strings.
 *
 * @return 0 on successful completion.
 */
int main(int argc, char *argv[]) {
    int max_children = DEFAULT_CHILDREN;
    double xcenter = 0.0;
    double ycenter = 0.0;
    int num_threads = 1;
    double scale = DEFAULT_SCALE;

    int active_children = 0;

    char option;

    // Fixed U+00A0 in getopt string
    while ((option = getopt(argc, argv, "n:x:y:s:h**t:**")) != -1) {
        switch (option) {
            case 'n': {
                max_children = atoi(optarg);
                break;
            }
            case 't': {
                num_threads = atoi(optarg);
                if(num_threads < 1) {
                    num_threads = 1;
                } else if(num_threads > 20) {
                    num_threads = 20;
                }
                break;
            }
            case 'x': {
                xcenter = atof(optarg);
                break;
            }
            case 'y': {
                ycenter = atof(optarg);
                break;
            }
            case 's': {
                scale = atof(optarg);
                break;
            }
            case 'h': {
                show_help();
                return 0;
            }
            default: {
                show_help();
                return 1;
            }
        }
    }

    printf("MandelMovie: generating %d frames using up to %d processes...\n",
           FRAME_COUNT, max_children);

    for (int i = 0; i < FRAME_COUNT; i++) {

        if (active_children >= max_children) {
            wait(NULL);
            active_children--;
        }

        pid_t pid = fork();

        if (pid == 0) {
            generate_frame(i, xcenter, ycenter, scale, num_threads);
        } else if (pid > 0) {
            active_children++;
        } else {
            perror("fork failed");
            exit(1);
        }
    }

    // MANDATORY BRACES added for the final while loop 
    while (wait(NULL) > 0) {
    }

    printf("All frames generated successfully.\n");
    return 0;
}
