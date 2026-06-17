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
│  • Monitors real-time tap interrupts         │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│       Device Driver Layer (adxl345.c)       │
│  • Sensor configuration                      │
│  • Burst-read acquisition                    │
│  • Register management                       │
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

System functionality was validated using a digital logic analyzer and controlled hardware test procedures.

## SPI Timing Verification

Captured SPI waveforms verified:

- Correct clock polarity and phase operation
- Proper chip-select timing
- Reliable transmit/receive sequencing
- Expected byte-transfer timing

Observed inter-byte gaps corresponded to software polling overhead rather than SPI peripheral limitations.

---

## Loopback Testing

SPI communication was validated using hardware loopback configurations.

### MISO Grounded

Produced:

```text
[0, 0, 0, 0]
```

confirming reliable low-state detection.

### MISO Connected to 3.3V

Produced:

```text
[255, 255, 255, 255]
```

confirming stable high-state reception.

---

## Accelerometer Validation

Verified:

- Correct sensor initialization
- Successful burst-read transactions
- Consistent axis measurements
- Accurate g-force conversion
- Reliable tap-event detection

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
