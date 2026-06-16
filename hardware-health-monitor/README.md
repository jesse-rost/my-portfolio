# Hardware Health Monitor

A real-time embedded sensor monitoring system developed on an ARM Cortex-M4 microcontroller (STM32F411). The system utilizes a custom cooperative round-robin task scheduler to poll system vital signs across a shared I2C bus and manages a multi-state interactive UI via an analog joystick and an 8×8 LED matrix.

---

# 🚀 System Architecture Overview

The system is engineered as a deterministic, lightweight embedded application built purely with direct memory-mapped register modifications (no high-level HAL dependencies).

The software architecture consists of three core structural pillars:

## Low-Level Hardware Layer
Custom low-level drivers managing register-level peripheral configurations for GPIO, I2C, ADC, and the SysTick timer (`regaddr.h`).

## Kernel Scheduler Layer
A bare-metal cooperative task scheduler (`roundRobin.c`) that divides CPU execution time between tasks using standard PendSV context switching.

## Application & FSM Layer
Dynamic data acquisition tasks feed values into a dedicated Finite State Machine (`display_task.c`) to control visual metrics and display behavior.

---

# 🛠️ Software & Peripheral Breakdown

## Cooperative Round-Robin Scheduler (`roundRobin.c` / `roundRobin.h`)

Operating with a base clock derived from a 1 ms periodic SysTick interrupt timer (`delay.c`), the scheduler provides multitasking without the overhead of a full RTOS.

### Features

#### Context Preservation
- Explicitly interfaces with ARM Cortex-M exception stack frames.
- Initializes task stacks by mimicking ISR entry behavior:
  - xPSR
  - PC
  - LR
  - R12
  - R3-R0
- Manually preserves R11-R4 during context switches.

#### Execution Swapping
- Forces context switches via PendSV.
- Uses the Interrupt Control and State Register (`SCB_ICSR`) to trigger scheduling events.

---

## Bare-Metal I2C Bus Driver (`i2c.c` / `i2c.h`)

A robust master-mode I2C execution layer configured to communicate with multiple peripherals over a shared bus.

### Features

- Start condition generation
- 7-bit slave addressing
- Byte Transfer Finished (BTF) validation
- Stop condition sequencing

### Fault Tolerance

Deterministic software timeouts (`TIMEOUT`) are implemented in all polling loops to guarantee that firmware never hard-locks if a peripheral disconnects or fails.

---

## State-Driven User Interface (`display_task.c` / `matrix.c`)

Visual output is controlled through a Finite State Machine (FSM) containing three primary states.

### DISPLAY_IDLE

- Renders a composite bar graph.
- Displays:
  - Voltage
  - Current
  - Temperature
- Columns are color-coded:
  - Green = Safe
  - Yellow = Warning
  - Red = Critical

Thresholds are defined in `matrix.h`.

### DISPLAY_SCROLLING

Triggered by joystick movement.

- Cycles through individual sensor metrics.
- Displays magnified numerical readouts.

### DISPLAY_RETURNING

Intermediate timeout state.

- Maintains the current focused metric.
- Counts down inactivity time.
- Automatically returns to `DISPLAY_IDLE` after 3 seconds.

---

## Interrupt-Driven Joystick Driver (`joystick.c` / `joystick.h`)

Interfaces with a two-axis analog joystick connected to:

- PA0
- PA1

### Features

- Continuous ADC scan mode using ADC1.
- Interrupt-driven updates via `ADC_IRQHandler`.
- Center-offset correction using `JOY_X_OFFSET`.
- Software deadband implementation:

```c
JOY_DEADBAND = 15
```

This suppresses:
- Signal noise
- Floating inputs
- Phantom navigation events

---

# 💡 Advanced Implementations Beyond Curriculum

This project required extensive use of manufacturer datasheets and low-level hardware analysis to bypass framework abstractions.

---

## 🔬 BME280 Calibration Formula Implementation

Accurate temperature measurement requires Bosch's fixed-point compensation algorithm rather than raw ADC readings.

### Initialization

During `bme280_init()`:

- Factory calibration constants are read directly from device memory.
- Trim values loaded:
  - `dig_T1`
  - `dig_T2`
  - `dig_T3`

### Processing

The runtime compensation algorithm:

- Uses integer-only arithmetic.
- Avoids floating-point overhead.
- Produces calibrated temperatures with:

```text
±0.01°C resolution
```

---

## ⚡ INA219 Precision Shunt Calibration

Rather than using default device parameters, the INA219 calibration register (`0x05`) is explicitly configured.

### Configuration

Known hardware values:

```text
Shunt Resistance = 0.1 Ω
Current_LSB      = 0.001 A
```

### Calibration Formula

```math
Cal = trunc(0.04096 / (Current_LSB × Rshunt))
```

### Result

```text
0x0199
```

Writing this value allows the INA219 to:

- Perform current calculations internally.
- Reduce MCU computation overhead.
- Improve measurement accuracy.

---

## 🎨 Shadow-Buffered Matrix Graphics & Custom Typography

The HT16K33 LED matrix does not provide native pixel-addressable text rendering.

To overcome this limitation, a custom font engine was implemented.

### Features

#### Custom Fonts

- 3×5 font set
- 3×3 compact font set

#### Shadow Buffer Rendering

```c
uint8_t shadowBuffer[16];
```

Characters are:

1. Rendered into RAM.
2. Composed column-by-column.
3. Manipulated using bit masking operations.

#### Atomic Display Updates

Once a frame is complete:

- Entire 16-byte buffer is transmitted in one I2C transaction.
- Eliminates visible flicker.
- Reduces bus overhead.

---

# 📂 Repository Layout

```text
hardware-health-monitor/
│
├── Inc/
│   ├── bme280.h          # Bosch temperature sensor driver
│   ├── delay.h           # SysTick clock core & timing utilities
│   ├── display_task.h    # FSM state definitions
│   ├── i2c.h             # Register-level I2C driver
│   ├── ina219.h          # Power monitor calibration macros
│   ├── joystick.h        # ADC configuration & calibration offsets
│   ├── matrix.h          # HT16K33 graphics thresholds
│   ├── regaddr.h         # Memory-mapped peripheral addresses
│   └── roundRobin.h      # PendSV stack frame mappings
│
└── Src/
    ├── bme280.c          # Compensation algorithms
    ├── delay.c           # SysTick timing engine
    ├── display_task.c    # Application FSM
    ├── i2c.c             # Safe I2C transactions
    ├── ina219.c          # Fixed-point current calculations
    ├── joystick.c        # ADC interrupt processing
    ├── main.c            # System initialization
    ├── matrix.c          # Font rendering & display updates
    └── roundRobin.c      # Context switching implementation
```

---

# 🛠️ Verification & Testing

System performance was verified using a digital logic analyzer.

## Timing Analysis

- GPIO validation pins used to mark execution boundaries.
- Verified scheduler timing accuracy.
- Confirmed 100 ms task intervals.

## I2C Signal Integrity

Monitored SDA and SCL lines to verify:

- Sensor polling transactions
- 16-byte matrix update bursts
- Absence of bus contention
- No lockups or collisions

## FSM Validation

Confirmed that:

- User interaction enters scrolling mode.
- Inactivity timeout expires at exactly 3000 ms.
- Display returns correctly to the default dashboard view.

---

# Author

**Jesse Rost**

**Email:** rostj@msoe.edu

**Course:** CPE 2610 – Embedded Systems Design Lab
