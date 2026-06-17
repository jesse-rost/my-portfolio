# Parallel Mandelbrot Fractal Renderer

A parallel fractal rendering application developed in C that combines multiprocessing and multithreading to accelerate Mandelbrot set image generation. The project utilizes POSIX threads, process management primitives (`fork`, `exec`, `wait`), and workload partitioning techniques to efficiently render a sequence of zooming fractal frames across multiple CPU cores.

The system generates a series of Mandelbrot images which can be assembled into a video, demonstrating practical performance scaling through concurrent execution and embarrassingly parallel computation.

---

# Overview

The application extends a provided Mandelbrot renderer by introducing both process-level and thread-level parallelism.

Image generation is divided into independent workloads that can be computed concurrently. Multiple child processes generate frames simultaneously while each frame is internally partitioned among multiple worker threads.

Because each pixel can be computed independently, the Mandelbrot calculation is highly parallelizable and scales effectively across modern multi-core processors.

---

# Key Features

- Multiprocess image generation using `fork()`
- Process execution through `exec()`
- POSIX thread-based image computation
- Configurable process count (`-n`)
- Configurable thread count (`-t`)
- Dynamic workload partitioning
- Command-line parameter parsing with `getopt()`
- Automatic frame generation
- Fractal zoom animation support
- Performance benchmarking and scalability analysis

---

# System Architecture

```text
                    mandelmovie
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
      Child 1         Child 2        Child N
         │               │               │
         ▼               ▼               ▼
      mandel          mandel         mandel
         │               │               │
         ▼               ▼               ▼
    Thread Pool     Thread Pool    Thread Pool
         │               │               │
         ▼               ▼               ▼
      Frame 1         Frame 2        Frame N
```

The parent process manages frame scheduling while child processes execute independent Mandelbrot render operations.

Within each child process, threads divide image regions and compute pixel values concurrently.

---

# Technical Highlights

## Multiprocessing Framework

The parent process generates a sequence of 50 animation frames.

For each frame:

- A child process is created using `fork()`
- Rendering parameters are calculated
- The child launches the renderer using `exec()`
- The parent continues scheduling additional work

The number of active child processes is limited using the `-n` command-line option.

This prevents excessive process creation and allows workload scaling based on available system resources.

---

## Multithreaded Image Rendering

Each Mandelbrot image is subdivided into independent regions.

Worker threads:

- Compute assigned pixel regions
- Operate without shared computation dependencies
- Write results directly into image buffers

Because each pixel calculation is independent, synchronization overhead remains extremely low.

This makes Mandelbrot rendering an example of an embarrassingly parallel workload.

---

## Dynamic Workload Scaling

The application supports independent configuration of:

```text
-n = Number of Processes
-t = Number of Threads
```

This enables experimentation with different concurrency configurations and allows performance analysis across a wide range of hardware resources.

---

## Frame-Based Animation Generation

The renderer automatically generates 50 sequential frames while continuously reducing the viewing scale.

Each frame:

- Maintains a common center point
- Increases zoom depth
- Produces a JPEG output image

The resulting frame sequence can be assembled into a smooth zoom animation.

---

# Performance Analysis

Execution times were measured across multiple process and thread configurations.

| Processes | Threads | Runtime (s) |
|------------|------------|-------------|
| 1 | 1 | 119.668 |
| 1 | 10 | 27.511 |
| 2 | 10 | 17.427 |
| 5 | 10 | 16.096 |
| 20 | 10 | 15.900 |

Complete benchmarking data is available in the repository.

![Runtime Graph](multithreadingVisual.png)

---

## Scaling Observations

Performance improved significantly as both process and thread counts increased.

The fastest measured execution time occurred at:

```text
20 Processes
10 Threads
15.900 Seconds
```

Beyond this point, additional concurrency produced diminishing returns due to:

- Thread scheduling overhead
- Process management costs
- CPU resource contention

The results demonstrate the importance of balancing parallel workload size against available hardware resources.

---

# Verification & Testing

System behavior was validated through repeated rendering runs and performance measurements.

## Functional Verification

Verified:

- Correct frame generation
- Proper zoom progression
- Successful process creation
- Accurate thread partitioning
- Complete image output generation

---

## Concurrency Validation

Confirmed:

- Process count limits enforced correctly
- Child processes terminate properly
- Thread workloads remain independent
- No image corruption during parallel rendering

---

## Performance Benchmarking

Measured execution times across:

- 5 process configurations
- 5 thread configurations

to evaluate scaling behavior and identify optimal execution parameters.

---

# Repository Structure

```text
parallel-mandelbrot-renderer/
│
├── mandelmovie.c
├── mandelmovie.h
├── mandel.c
├── multithreadingVisual.png
├── frame_00.jpg
├── ...
├── frame_49.jpg
├── mandel.mp4
└── README.md
```

---

# Build & Run

## Build

```bash
make
```

## Run Examples

```bash
./mandelmovie -n 10 -t 10
```

```bash
./mandelmovie -n 5 -t 5 -x -0.5 -y -0.5 -s 2.0
```

### Command-Line Options

```text
-n <children>   Maximum concurrent child processes
-t <threads>    Number of rendering threads
-x <value>      Mandelbrot center X coordinate
-y <value>      Mandelbrot center Y coordinate
-s <value>      Initial zoom scale
-h              Display help information
```

---

## Video Generation

Generated frames can be combined into a video using FFmpeg:

```bash
ffmpeg -framerate 30 -i frame_%02d.jpg mandel.mp4
```

---

# Key Concepts Demonstrated

- POSIX process management
- Fork/Exec programming model
- Multithreaded computation
- Workload partitioning
- Embarrassingly parallel algorithms
- Process synchronization
- CPU performance scaling
- Command-line argument parsing
- High-performance image generation
- Systems programming in C

---

# Author

**Jesse Rost**

**Course:** CPE 2600 – Systems Programming
