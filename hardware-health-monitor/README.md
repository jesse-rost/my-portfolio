Hardware Health Monitor

A real-time embedded sensor monitoring system developed on an ARM Cortex-M4 microcontroller (STM32F411). The system utilizes a custom, cooperative round-robin task scheduler to poll system vital signs across a shared I2C bus and manages a multi-state interactive UI via an analog joystick and an 8x8 LED matrix.

🚀 System Architecture Overview

The system is engineered as a deterministic, lightweight embedded application built purely with direct memory-mapped register modifications (no high-level HAL dependencies).

The software architecture consists of three core structural pillars:

Low-Level Hardware Layer: Custom low-level drivers managing register-level peripheral configurations for GPIO, I2C, ADC, and the SysTick timer (regaddr.h).

Kernel Scheduler Layer: A bare-metal cooperative task scheduler (roundRobin.c) that divides CPU execution time between tasks using standard PendSV context switching.

Application & FSM Layer: Dynamic data acquisition tasks that feed values into a dedicated Finite State Machine (display_task.c) to control visual metrics.

🛠️ Software & Peripheral Breakdown

1. Cooperative Round-Robin Scheduler (roundRobin.c / roundRobin.h)

Operating with a base clock derived from a 1ms periodic SysTick interrupt timer (delay.c), the scheduler provides multi-tasking blocks without the full overhead of an RTOS.

Context Preservation: Explicitly interfaces with standard ARM architecture context saving; sets up individual task stacks by mimicking ISR behavior (pushing xPSR, PC, LR, R12, R3-R0, and manually preserving R11-R4).

Execution Swapping: Triggers a context switch by forcing the PendSV handler via the Interrupt Control and State Register (SCB_ICSR).

2. Bare-Metal I2C Bus Driver (i2c.c / i2c.h)

A robust master-mode I2C execution layer configured to communicate with multiple peripherals over a single bus using safe sequencing loops:

Features independent block definitions handling Start condition generation, 7-bit slave addressing confirmation, Byte Transfer Finished (BTF) validation, and Stop condition sequencing.

Employs deterministic software timeouts (TIMEOUT) within polling checks to guarantee the firmware will never hard-lock or freeze if a sensor encounters a hardware disconnect.

3. State-Driven User Interface (display_task.c / matrix.c)

Visual output is regulated by a strict Finite State Machine containing three execution loops:

DISPLAY_IDLE: Renders a composite bar graph showing Voltage, Current, and Temperature concurrently. Columns are green, yellow, or red based on strict safety bounds defined in matrix.h.

DISPLAY_SCROLLING: Triggered by joystick displacement. Cycles through single-metric, magnified numerical text views.

DISPLAY_RETURNING: An intermediary timeout loop that keeps the current numerical readout focused but counts down; after 3 seconds of inactivity, it seamlessly transitions the view back to the standard Idle bar graph.

4. Interrupt-Driven Joystick Driver (joystick.c / joystick.h)

Interfaces an analog two-axis joystick with pins PA0 and PA1.

Uses continuous scanning mode through ADC1 synchronized via the ADC_IRQHandler interrupt vector.

Implements mathematical centering offsets (JOY_X_OFFSET) and an algorithmic software deadband (JOY_DEADBAND = 15) to mitigate hardware floating, signal noise, and phantom navigation events.

💡 Advanced Implementations Beyond Curriculum

This project required deep analysis of manufacturer datasheets and raw hardware math manipulation to bypass traditional framework limitations:

🔬 BME280 Calibration Formula Implementation

Reading temperature accurately from the Bosch BME280 required more than pulling raw ADC values. The production implementation incorporates the exact multi-step fixed-point calibration sequence extracted from the device's technical datasheet.

During initialization (bme280_init), factory-fused trim parameters (dig_T1, dig_T2, dig_T3) are parsed directly out of non-volatile memory registers.

The processing loop applies integer-based scaling adjustments, resolving raw sensor data into calibrated readouts scaled to $1/100\text{th}$ of a degree Celsius ($\pm 0.01^\circ\text{C}$ resolution) without needing a heavy floating-point arithmetic library unit.

⚡ INA219 Precision Shunt Calibration

Rather than operating on basic default parameters, the Texas Instruments INA219 driver explicitly provisions the internal hardware Math Calibration Register (0x05).

Using a known configuration based on a $0.1\,\Omega$ physical shunt resistor on the peripheral module, a precise Current Least Significant Bit (Current_LSB = 0.001) was chosen.

Using the mathematical formula:


$$\text{Cal} = \text{trunc}\left(\frac{0.04096}{\text{Current\_LSB} \times R_{\text{Shunt}}}\right)$$

The value 0x0199 was flashed to the device. This configuration offloads multiplication cycles from the microcontroller core, allowing the INA219 to calculate and provide current directly via I2C with optimal accuracy.

🎨 Shadow-Buffered Matrix Graphics & Custom Typography

The HT16K33 LED matrix lacks pixel-addressable text manipulation. To overcome this limitation, a custom font rendering engine was designed from scratch:

Engineered standard, pixel-mapped character tables ($3\times5$ and $3\times3$ font matrices) directly within the graphics system.

Implemented a Shadow Buffer array (uint8_t shadowBuffer[16]) inside system memory. Characters are rendered into the buffer column-by-column using bitwise masking.

Once frame rendering concludes, the entire 16-byte layout is flushed across the I2C bus to the display controller in a single atomic transaction, dramatically reducing bus overhead and eliminating graphic flickering.

📂 Repository Layout

├── hardware-health-monitor/
│   ├── Inc/
│   │   ├── bme280.h        # Bosch Temperature Sensor Driver Headers
│   │   ├── delay.h         # SysTick Clock Core & Millisecond Utilities
│   │   ├── display_task.h  # State Machine State Definitions
│   │   ├── i2c.h           # Bare-Metal Register-Level I2C Bus Headers
│   │   ├── ina219.h        # Power Monitor Calibration Macro Layouts
│   │   ├── joystick.h      # ADC Configurations & Calibration Offsets
│   │   ├── matrix.h        # HT16K33 Graphics Threshold Maps
│   │   ├── regaddr.h       # Direct Memory-Mapped Peripheral Address Structs
│   │   └── roundRobin.h    # PendSV Stack Frame Reference Mapping
│   └── Src/
│       ├── bme280.c        # Compensation Math Implementation
│       ├── delay.c         # SysTick 1ms Interrupt & Delay Loops
│       ├── display_task.c  # Main Application Core & Finite State Machine
│       ├── i2c.c           # Master-Mode Safe Read/Write Sequencing
│       ├── ina219.c        # Fixed-Point Current Math Driver
│       ├── joystick.c      # ADC Continuous Scan & Interrupt Service Vector
│       ├── main.c          # Kernel Initialization & Hardware Boot Entry
│       ├── matrix.c        # Custom Font Engine & Shadow-Buffer Flush
│       └── roundRobin.c    # Context Preservation Thread Assembly Swapping


🛠️ Verification & Testing

System performance was verified utilizing a digital logic analyzer to measure execution boundaries and bus stability:

Timing Analysis: The cooperative thread scheduler was timed via toggling GPIO validation pins, confirming accurate task slicing down to target 100ms intervals.

I2C Signal Integrity: Monitored cross-device commands on lines SDA / SCL, confirming that single-byte sensor polls and full 16-byte matrix buffer bursts do not collide or cause bus lockup.

FSM Validation: Verified that the display timeout correctly returns to the default screen exactly 3000ms after the last joystick input edge.

Author: Jesse Rost

Contact: rostj@msoe.edu

Course Context: CPE 2610 - Embedded Systems Design Lab