/// 
//  mandel.c
//  Based on example code found here:
//  https://users.cs.fiu.edu/~cpoellab/teaching/cop4610_fall22/project3.html
//
//  Converted to use jpg instead of BMP and other minor changes
//  
///
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "jpegrw.h"
#include <pthread.h>

// Structure to pass arguments to each thread
typedef struct {
    imgRawImage* img;
    double xmin, xmax, ymin, ymax;
    int max_iters;
    int start_row; // Start row index (j) for this thread's region
    int end_row;   // End row index (j), exclusive
} thread_args_t;

// local routines
static int iteration_to_color( int i, int max );
static int iterations_at_point( double x, double y, int max );
// UPDATED: Added num_threads argument to compute_image
static void compute_image( imgRawImage *img, double xmin, double xmax,
                                         double ymin, double ymax, int max, int num_threads ); 
static void show_help();

// ADDED: Prototype for the thread function
static void* thread_compute_image(void* args); 


int main( int argc, char *argv[] )
{
    char c;

    // These are the default configuration values used
    // if no command line arguments are given.
    const char *outfile = "mandel.jpg";
    double xcenter = 0;
    double ycenter = 0;
    double xscale = 4;
    double yscale = 0; // calc later
    int    image_width = 1000;
    int    image_height = 1000;
    int    max = 1000;
    int num_threads = 1; // Default thread count

    // For each command line argument given,
    // override the appropriate configuration value.

    // Fixed U+00A0 in getopt string
    while((c = getopt(argc,argv,"x:y:s:W:H:m:o:h**t:**"))!=-1) {
        switch(c) 
        {
            case 'x':
                xcenter = atof(optarg);
                break;
            case 'y':
                ycenter = atof(optarg);
                break;
            case 's':
                xscale = atof(optarg);
                break;
            case 'W':
                image_width = atoi(optarg);
                break;
            case 'H':
                image_height = atoi(optarg);
                break;
            case 'm':
                max = atoi(optarg);
                break;
            case 'o':
                outfile = optarg;
                break;
            case 't': // Handle thread count argument
                num_threads = atoi(optarg);
                if(num_threads < 1) num_threads = 1;
                else if(num_threads > 20) num_threads = 20;
                break;
            case 'h':
                show_help();
                exit(1);
                break;
        }
    }

    // Calculate y scale based on x scale (settable) and image sizes in X and Y (settable)
    yscale = xscale / image_width * image_height;

    // Display the configuration of the image.
    printf("mandel: x=%lf y=%lf xscale=%lf yscale=%1f max=%d threads=%d outfile=%s\n",
           xcenter,ycenter,xscale,yscale,max,num_threads,outfile);

    // Create a raw image of the appropriate size.
    imgRawImage* img = initRawImage(image_width,image_height);

    // Fill it with a black
    setImageCOLOR(img,0);

    // Compute the Mandelbrot image
    compute_image(img,xcenter-xscale/2,xcenter+xscale/2,ycenter-yscale/2,ycenter+yscale/2,max, num_threads);

    // Save the image in the stated file.
    storeJpegImageFile(img,outfile);

    // free the mallocs
    freeRawImage(img);

    return 0;
}


/*
Return the number of iterations at point x, y
in the Mandelbrot space, up to a maximum of max.
*/
int iterations_at_point( double x, double y, int max )
{
    double x0 = x;
    double y0 = y;

    int iter = 0;

    while( (x*x + y*y <= 4) && iter < max ) {

        double xt = x*x - y*y + x0;
        double yt = 2*x*y + y0;

        x = xt;
        y = yt;

        iter++;
    }

    return iter;
}

// Thread worker function. Calculates the mandelbrot set for a specific row range.
static void* thread_compute_image(void* args)
{
    // Cast the void* back to the thread_args_t pointer
    thread_args_t* p_args = (thread_args_t*)args;
    
    // Extract variables from the struct
    imgRawImage* img = p_args->img;
    double xmin = p_args->xmin;
    double xmax = p_args->xmax;
    double ymin = p_args->ymin;
    double ymax = p_args->ymax;
    int max_iters = p_args->max_iters;
    int start_row = p_args->start_row;
    int end_row = p_args->end_row;

    int width = img->width;
    int height = img->height;

    // The outer loop (j) is now constrained to the thread's allocated region
    for(int j = start_row; j < end_row; j++) {
        for(int i=0; i<width;i++) {
            // Determine the point in x,y space for that pixel.
            double x = xmin + i*(xmax-xmin)/width;
            double y = ymin + j*(ymax-ymin)/height; 

            // Compute the iterations at that point.
            int iters = iterations_at_point(x,y,max_iters);

            // Set the pixel in the bitmap.
            setPixelCOLOR(img,i,j,iteration_to_color(iters,max_iters));
        }
    }
    
    return NULL; 
}


/*
Compute an entire Mandelbrot image, writing each point to the given bitmap.
Scale the image to the range (xmin-xmax,ymin-ymax), limiting iterations to "max"
*/
void compute_image(imgRawImage* img, double xmin, double xmax, double ymin, double ymax, int max, int num_threads )
{
    int height = img->height;
    
    // Allocate memory for thread IDs and argument structs
    pthread_t* threads = malloc(num_threads * sizeof(pthread_t));
    thread_args_t* args = malloc(num_threads * sizeof(thread_args_t));
    
    if (threads == NULL || args == NULL) {
        perror("Failed to allocate memory for threads or arguments");
        if (threads) free(threads);
        if (args) free(args);
        return;
    }

    // 1. Calculate the work distribution and launch threads
    int rows_per_thread = height / num_threads;
    int current_row = 0;
    
    for (int k = 0; k < num_threads; k++) {
        
        // Determine the row range for this thread
        args[k].start_row = current_row;
        // The last thread gets any remaining rows (handling height % num_threads != 0)
        args[k].end_row = (k == num_threads - 1) 
                          ? height 
                          : current_row + rows_per_thread;
        
        // Set the rest of the common arguments
        args[k].img = img;
        args[k].xmin = xmin;
        args[k].xmax = xmax;
        args[k].ymin = ymin;
        args[k].ymax = ymax;
        args[k].max_iters = max;

        // Launch the thread. Pass the address of the specific argument struct.
        if (pthread_create(&threads[k], NULL, thread_compute_image, &args[k]) != 0) {
            perror("Thread creation failed");
            // NOTE: A robust program would clean up launched threads here.
            break; 
        }
        
        current_row = args[k].end_row;
    }

    // 2. Wait for all launched threads to complete (join)
    for (int k = 0; k < num_threads; k++) {
        pthread_join(threads[k], NULL);
    }
    
    // 3. Clean up
    free(threads);
    free(args);
}


/*
Convert a iteration number to a color.
Here, we just scale to gray with a maximum of imax.
Modify this function to make more interesting colors.
*/
int iteration_to_color( int iters, int max )
{
    int color = 0xFFFF111*iters/(double)max;
    return color;
}


// Show help message
void show_help()
{
    printf("Use: mandel [options]\n");
    printf("Where options are:\n");
    printf("-m <max>    The maximum number of iterations per point. (default=1000)\n");
    printf("-t <max>    The maximum number of threads to use (1-20). (default=1)\n");
    printf("-x <coord>  X coordinate of image center point. (default=0)\n");
    printf("-y <coord>  Y coordinate of image center point. (default=0)\n");
    printf("-s <scale>  Scale of the image in Mandlebrot coordinates (X-axis). (default=4)\n");
    printf("-W <pixels> Width of the image in pixels. (default=1000)\n");
    printf("-H <pixels> Height of the image in pixels. (default=1000)\n");
    printf("-o <file>   Set output file. (default=mandel.bmp)\n");
    printf("-h          Show this help text.\n");
    printf("\nSome examples are:\n");
    printf("mandel -x -0.5 -y -0.5 -s 0.2\n");
    printf("mandel -x -.38 -y -.665 -s .05 -m 100\n");
    printf("mandel -x 0.286932 -y 0.014287 -s .0005 -m 1000\n\n");
}
