# Hardware Health Monitor

A real-time embedded monitoring system developed on an STM32F411 ARM Cortex-M4 microcontroller. The application continuously acquires voltage, current, and temperature measurements over a shared I2C bus and presents system health information through an interactive LED matrix user interface.

Built entirely using direct memory-mapped register manipulation, the project demonstrates bare-metal embedded systems development, custom task scheduling, sensor integration, interrupt-driven input handling, and real-time graphical rendering without STM32 HAL libraries or a traditional RTOS.

---

# Overview

The system is structured as a lightweight embedded application composed of three primary software layers:

1. **Low-Level Hardware Layer**
   - Register-level peripheral drivers
   - Direct memory-mapped hardware access
   - No HAL dependencies

2. **Cooperative Scheduler Layer**
   - Custom round-robin task scheduler
   - PendSV-based context switching
   - SysTick-driven task timing

3. **Application Layer**
   - Sensor acquisition tasks
   - State-driven user interface
   - Interactive display management

Together these layers provide deterministic execution while maintaining a small memory footprint suitable for resource-constrained embedded systems.

---

# System Architecture

```text
┌──────────────────────────────────────────────┐
│                Application Layer             │
│    Display FSM & Sensor Processing Tasks     │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│           Cooperative Scheduler Layer        │
│     Round-Robin Task Scheduling Engine       │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│          Low-Level Hardware Drivers          │
│ GPIO │ I2C │ ADC │ SysTick │ Interrupts      │
└──────────────────────────────────────────────┘
```

---

# Hardware Components

| Component | Purpose |
|------------|------------|
| STM32F411RE | ARM Cortex-M4 Microcontroller |
| BME280 | Temperature Sensor |
| INA219 | Voltage & Current Monitor |
| HT16K33 | LED Matrix Driver |
| 8×8 RGB LED Matrix | Visual Output |
| Analog Joystick | User Input |

---

# Software & Peripheral Breakdown

## Cooperative Scheduler (`roundRobin.c` / `roundRobin.h`)

The scheduler operates from a 1 ms SysTick interrupt source and provides lightweight cooperative multitasking without requiring an RTOS.

### Features

- Manual task stack construction
- ARM exception-frame emulation
- Register preservation (R4–R11)
- SysTick-based timing
- PendSV context switching

### Context Management

Task stacks are initialized by constructing Cortex-M exception frames containing:
- xPSR
- PC
- LR
- R12
- R3–R0

Additional registers are preserved and restored during context switches.

### Context Switching

Execution transfers are triggered through the PendSV exception by setting the pending bit in the Interrupt Control and State Register (`SCB_ICSR`).

---

## Bare-Metal I2C Driver (`i2c.c` / `i2c.h`)

A custom master-mode I2C implementation manages communication with all external peripherals on the shared bus.

### Features

- Start condition generation
- 7-bit slave addressing
- Address acknowledgment verification
- Byte Transfer Finished (BTF) validation
- Stop condition generation
- Multi-byte transactions

### Fault Protection

Deterministic timeout protection prevents firmware lockups during bus faults or peripheral disconnects.

```c
const int TIMEOUT = 10000;
```

This ensures the system remains responsive even if a device becomes unavailable.

---

## State-Driven User Interface (`display_task.c` / `matrix.c`)

Visual output is regulated by a strict Finite State Machine (FSM). Because an 8×8 LED matrix introduces severe character layout constraints, a custom font-masking engine optimizes pixel space to toggle between a system overview bar graph and individual magnified sensor screens.

### Live UI State Gallery

| 📊 System Overview (Idle) | 🌡️ Temperature View (21°C) |
| :---: | :---: |
| <img src="docs/display_idle.jpg" width="300" alt="FSM Idle State"> | <img src="docs/display_temp.jpg" width="300" alt="Temperature Display View"> |
| *Active multi-column real-time telemetry bar graph operating in safe status.* | *Magnified ambient environment thermal reading processed through the Bosch driver.* |

| ⚡ Voltage View (2.7V) | 🔌 Current View (12 mA) |
| :---: | :---: |
| <img src="docs/display_voltage.jpg" width="300" alt="Voltage Display View"> | <img src="docs/display_current.jpg" width="300" alt="Current Display View"> |
| *Real-time system rail voltage reading packed tightly into a custom 3×5 numeric font.* | *Live bus current draw measured via the INA219 precision shunt module.* |

---

### ⏳ DISPLAY_RETURNING State

An intermediary software counter state that acts as an interface timeout. If the user stops shifting the joystick on any individual sensor screen, the FSM holds that metric in focus for exactly **3000 ms** before automatically transitioning execution safely back to the default `DISPLAY_IDLE` bar graph overview.

---

## Interrupt-Driven Joystick Driver (`joystick.c` / `joystick.h`)

The joystick subsystem interfaces with a two-axis analog joystick connected to:
- PA0 (X-axis)
- PA1 (Y-axis)

### Features

- ADC scan mode
- Continuous conversion mode
- Interrupt-driven sampling
- Overrun recovery
- Calibration offsets
- Deadband filtering

### Noise Filtering

The driver applies configurable offsets and software deadbands:

```c
JOY_DEADBAND = 15
```

to eliminate:
- Analog noise
- Mechanical centering drift
- False navigation events

This provides responsive user interaction without requiring polling loops in application code.

---

# Advanced Implementations

## BME280 Temperature Compensation

Accurate temperature measurements require Bosch's fixed-point compensation algorithm rather than raw ADC values.

### Initialization

During startup:
- Factory trim values are read directly from sensor memory
- Calibration coefficients loaded: `dig_T1`, `dig_T2`, `dig_T3`

### Runtime Processing

The compensation algorithm:
- Uses integer arithmetic
- Avoids floating-point overhead
- Implements Bosch's datasheet-defined calculations

Resulting measurements achieve approximately ±0.01°C resolution while remaining computationally efficient.

---

## INA219 Current Calibration

The INA219 calibration register (`0x05`) is explicitly configured rather than relying on default settings.

### Configuration

```text
Shunt Resistance = 0.1 Ω
Current_LSB      = 0.001 A
```

### Calibration Formula

```text
Cal = trunc(0.04096 / (Current_LSB × Rshunt))
```

### Result

```text
0x0199
```

Programming this value allows the INA219 to perform current calculations internally, reducing processor workload and improving measurement accuracy.

---

## Shadow-Buffered Graphics Engine

The HT16K33 LED matrix does not provide native text-rendering functionality. To support dynamic numerical displays, a custom graphics engine was implemented.

### Custom Fonts

Two bitmap font sets were created:
- 3×5 numeric font
- 3×3 engineering unit font

### Shadow Buffer

```c
uint8_t shadowBuffer[16];
```

All rendering occurs in memory before transmission.

### Atomic Updates

Once rendering is complete:
- The entire 16-byte frame buffer is transmitted in a single I2C transaction
- Display flicker is eliminated
- Bus traffic is minimized

---

# Repository Layout

```text
hardware-health-monitor/
│
├── docs/
│   ├── display_idle.jpg       # Composite overview bar-graph view
│   ├── display_voltage.jpg    # 2.7V rail tracking screen
│   ├── display_current.jpg    # 12 mA consumption screen
│   └── display_temp.jpg       # 21°C compensated thermal screen
│
├── Inc/
│   ├── bme280.h
│   ├── delay.h
│   ├── display_task.h
│   ├── i2c.h
│   ├── ina219.h
│   ├── joystick.h
│   ├── matrix.h
│   ├── regaddr.h
│   └── roundRobin.h
│
└── Src/
    ├── bme280.c
    ├── delay.c
    ├── display_task.c
    ├── i2c.c
    ├── ina219.c
    ├── joystick.c
    ├── main.c
    ├── matrix.c
    └── roundRobin.c
```

---

# Testing & Validation

System operation was verified using runtime instrumentation and digital logic analyzer measurements.

## Scheduler Timing Verification

GPIO instrumentation was used to observe:
- Task execution intervals
- Scheduler timing accuracy
- Context-switch behavior

Measured timing aligned with the intended 1 ms SysTick scheduling framework.

### I2C Bus Validation

Logic analyzer captures verified:
- Sensor polling transactions
- Display update transfers
- Correct start/stop sequences
- Reliable timeout recovery
- Absence of bus contention

### FSM Verification

Testing confirmed:
- Correct state transitions
- Reliable joystick navigation
- Automatic return-to-idle behavior after 3000 ms
- Stable display rendering across all operating modes

---

# Key Learning Outcomes

This project provided practical experience with:
- Bare-metal STM32 development
- ARM Cortex-M exception handling
- PendSV-based context switching
- Cooperative task scheduling
- Register-level peripheral configuration
- I2C protocol implementation
- Interrupt-driven ADC acquisition
- Finite State Machine design
- Embedded graphics rendering
- Sensor calibration algorithms
- Real-time debugging using logic analyzers

---

# Author

**Jesse Rost**


**Course:** CPE 2610 – Embedded Systems Design Lab
```
