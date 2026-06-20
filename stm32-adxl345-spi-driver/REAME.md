# STM32 Bare-Metal SPI & ADXL345 Accelerometer Driver

A register-level SPI master driver and layered ADXL345 accelerometer application developed for the ARM Cortex-M4 STM32F411 microcontroller. The project bypasses STM32 HAL libraries and interfaces directly with memory-mapped peripheral registers, demonstrating low-level serial communication, device driver design, and hardware verification techniques.

The software architecture separates generic SPI bus management from device-specific accelerometer functionality, creating a reusable embedded driver stack capable of supporting additional SPI peripherals with minimal modification.

---

# Overview

The project implements a complete SPI communication stack for interfacing with an ADXL345 three-axis accelerometer.

A generic SPI master driver provides low-level bus control while a dedicated ADXL345 driver manages sensor configuration, burst data acquisition, and tap-event monitoring.

Acceleration data is collected through atomic multi-byte transactions and converted into calibrated g-force measurements for real-time monitoring and analysis.

---

# Key Features

- Bare-metal STM32F411 development
- Register-level SPI peripheral configuration
- Motorola SPI Modes 0–3 support
- Software-controlled chip select management
- Full-duplex SPI transaction engine
- ADXL345 accelerometer integration
- Atomic multi-byte burst reads
- Tap-event detection support
- UART diagnostic output
- Logic analyzer-based hardware validation

---

# System Architecture

```text
┌─────────────────────────────────────────────┐
│          Application Layer (test.c)         │
│  • Converts raw acceleration to g-force     │
│  • Monitors real-time tap interrupts        │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│       Device Driver Layer (adxl345.c)       │
│  • Sensor configuration                     │
│  • Burst-read acquisition                   │
│  • Register management                      │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│        SPI Driver Layer (spi_api.c)         │
│  • SPI Modes 0–3                            │
│  • Software chip select                     │
│  • Full-duplex transaction engine           │
└─────────────────────────────────────────────┘
```

The layered architecture isolates hardware communication from sensor-specific functionality, improving modularity and reusability across embedded projects.

---

# Technical Highlights

## Register-Level SPI Driver

The SPI implementation directly configures STM32 SPI1 registers without relying on vendor-provided middleware.

The driver manages:

- GPIO alternate-function configuration
- Clock initialization
- SPI mode selection
- Baud-rate configuration
- Master-mode operation
- Software-controlled chip select

This approach provides complete control over hardware behavior while minimizing software overhead.

---

## Three-Phase Transaction Engine

SPI communication is handled through a flexible transaction engine supporting mixed read/write operations.

### Write Phase

- Sends command bytes
- Discards incoming shift-register data
- Prevents receive buffer overrun conditions

### Overlap Phase

- Performs simultaneous transmit and receive operations
- Supports command-response peripherals

### Read Phase

- Generates clock edges using dummy writes
- Captures incoming slave data

This design enables support for a wide variety of SPI devices using a single reusable API.

---

## ADXL345 Accelerometer Driver

The device-specific driver manages all accelerometer configuration and measurement tasks.

Features include:

- Standby-mode configuration
- Measurement-mode initialization
- Full-resolution operation
- Tap-detection support
- Multi-byte burst acquisition

The driver abstracts sensor-specific register operations from application code while leveraging the generic SPI layer.

---

## Atomic Burst Data Acquisition

To prevent axis data corruption during sensor updates, all three acceleration axes are acquired using a single six-byte SPI burst transaction.

Benefits include:

- Consistent X/Y/Z sampling
- No inter-axis timing skew
- Reduced bus overhead
- Improved measurement integrity

The burst-read implementation ensures all axis measurements originate from the same sensor sample period.

---

## Real-Time Acceleration Scaling

Raw 16-bit sensor measurements are converted into physical acceleration values using the ADXL345 Full-Resolution scale factor.

```text
4 mg/LSB
```

Conversion:

```text
Acceleration = Raw Value × 0.004 g
```

This produces calibrated acceleration measurements directly in units of gravitational acceleration.

---

# Verification & Testing

System functionality was validated using a digital logic analyzer alongside automated test assertions to verify protocol compliance and hardware timing margin.

## Loopback & Waveform Analysis

To isolate peripheral behavior from the physical sensor, initial verification was performed using external hardware loopback configurations under varying clock frequencies.

![SPI Logic Analyzer Capture](docs/spi_waveform.png)

*Logic analyzer capture highlighting the timing differences between high-speed and normal-speed transaction loops.*

### 1. Timing & Polling Overhead (Top & Middle Panels)
The first two panels capture the system operating in a **high-speed loopback** configuration. 
* **Clock Dynamics:** The serial clock speed is significantly accelerated compared to standard operation.
* **The Software Gap:** When zooming into the middle capture, a distinct transmission gap appears between the final clock edge of a byte transaction and the starting clock edge of the next block. 
* **Root Cause:** This delay is entirely introduced by software execution. The ARM core must poll the SPI status flags (such as TXE and RXNE) inside the data loop before loading the next byte. This cleanly illustrates the real-world performance cost of blocking register-level polling handlers.

### 2. Standard Loopback (Bottom Panel)
The third panel illustrates a **normal-speed loopback** sequence. Because the communication clock is slower, the relative percentage of CPU polling overhead is greatly reduced, resulting in tighter sequential byte blocks on the physical wire.

---

## Automated Test Harness

A custom validation suite was implemented inside `test.c` to rigorously exercise the full-duplex engine.

* **Methodology:** The test suite systematically executes the transaction layer by passing a variety of deterministic payloads through the `spi_wr()` driver function.
* **Assertion Testing:** Received data buffers are continuously evaluated against hardcoded expected results to ensure 100% data integrity.
* **Hardware Loopback Validation:** * **MISO Grounded:** Produced `[0, 0, 0, 0]`, verifying stable low-state threshold detection.
  * **MISO to 3.3V:** Produced `[255, 255, 255, 255]`, confirming consistent high-state bus logic.

---

## Accelerometer Integration Validation

Once bus timing and software drivers were proven stable, physical sensor validation confirmed:
* Successful ADXL345 device ID handshake initialization.
* Stable multi-byte atomic burst reads across all three physical axes concurrently.
* Clean real-time conversion of raw binary values into physical g-force thresholds.
* Reliable trigger capturing via tap-event interrupt pins.

---

# Repository Structure

```text
stm32-adxl345-spi-driver/
│
├── Inc/
│   ├── spi_api.h
│   ├── adxl345.h
│   ├── regaddr.h
│   ├── delay.h
│   ├── uart.h
│   └── test.h
│
└── Src/
    ├── spi_api.c
    ├── adxl345.c
    ├── test.c
    ├── delay.c
    ├── uart.c
    ├── main.c
    ├── syscalls.c
    └── sysmem.c
```

---

# Build & Run

## Build

```bash
make
```

## Flash to Target

Load the generated binary onto the STM32F411 development board using STM32CubeProgrammer, ST-Link Utility, or an equivalent programming interface.

## Execute

Power the target system and monitor output through the configured UART serial interface.

---

# Key Concepts Demonstrated

- Bare-metal STM32 development
- Register-level peripheral programming
- SPI protocol implementation
- Full-duplex serial communication
- Layered embedded driver architecture
- Device-driver abstraction
- Multi-byte burst transactions
- Hardware timing analysis
- Logic analyzer debugging
- Accelerometer calibration and scaling

---

# Author

**Jesse Rost**

**Email:** rostj@msoe.edu

**Course:** CPE 2610 – Embedded Systems Design Lab
