# Hardware Health Monitor

A real-time embedded sensor monitoring system developed on an ARM Cortex-M4 microcontroller (STM32F411). The system polls voltage, current, and temperature sensors over a shared I2C bus and presents system health metrics through an interactive state-driven user interface controlled by an analog joystick and an 8×8 RGB LED matrix.

Built entirely with direct memory-mapped register manipulation, the project demonstrates bare-metal embedded development without reliance on STM32 HAL libraries or a full RTOS.

---

# 🚀 System Architecture Overview

The system is structured as a lightweight embedded application composed of three primary software layers:

## Low-Level Hardware Layer

Custom register-level peripheral drivers provide direct hardware access for:

- GPIO
- I2C
- ADC
- SysTick Timer

All peripheral configuration is performed through direct memory-mapped register manipulation (`regaddr.h`), eliminating framework overhead and providing deterministic control of the hardware.

## Cooperative Scheduler Layer

A custom cooperative task scheduler (`roundRobin.c`) provides lightweight task execution using ARM Cortex-M PendSV context switching.

### Features

- Manual task stack construction
- ARM exception-frame emulation
- Register preservation (R4-R11)
- SysTick-driven scheduling events
- PendSV-based context switching

The scheduler framework supports multiple concurrent tasks while maintaining a significantly smaller footprint than a traditional RTOS. In the current implementation, the scheduler manages the primary sensor acquisition and display task alongside the main execution context.

## Application & FSM Layer

Application logic is built around a Finite State Machine (FSM) responsible for rendering system metrics and processing user input.

Sensor measurements are collected and forwarded to the display subsystem, which dynamically switches between graphical and numerical visualization modes.

---

# 🔧 Hardware Used

| Component | Purpose |
|------------|------------|
| STM32F411RE | ARM Cortex-M4 Microcontroller |
| BME280 | Temperature Sensor |
| INA219 | Voltage & Current Monitor |
| HT16K33 | LED Matrix Driver |
| 8×8 RGB LED Matrix | Visual Output |
| Analog Joystick | User Input |

---

# 🛠️ Software & Peripheral Breakdown

## Cooperative Round-Robin Scheduler (`roundRobin.c` / `roundRobin.h`)

Operating from a 1 ms SysTick interrupt source, the scheduler performs cooperative task switching without requiring an external operating system.

### Context Preservation

Task stacks are initialized by manually constructing Cortex-M exception frames containing:

- xPSR
- PC
- LR
- R12
- R3-R0

Additional registers (R4-R11) are preserved and restored during PendSV context switches.

### Execution Swapping

Context switches are triggered by setting the PendSV pending bit through the ARM Interrupt Control and State Register (`SCB_ICSR`).

This approach provides deterministic task execution while maintaining minimal runtime overhead.

---

## Bare-Metal I2C Bus Driver (`i2c.c` / `i2c.h`)

A custom master-mode I2C driver provides communication with all external peripherals on a shared bus.

### Features

- Start condition generation
- 7-bit slave addressing
- Address acknowledgment verification
- Byte Transfer Finished (BTF) validation
- Stop condition generation
- Multi-byte read/write support

### Fault Tolerance

All polling operations utilize deterministic software timeout protection.

```c
const int TIMEOUT = 10000;
```

This prevents firmware lockup if a sensor disconnects, fails to acknowledge, or experiences a bus fault.

---

## State-Driven User Interface (`display_task.c` / `matrix.c`)

Visual output is controlled by a dedicated Finite State Machine.

### DISPLAY_IDLE

Displays a composite bar graph representing:

- Voltage
- Current
- Temperature

Values are color-coded according to configurable safety thresholds:

- Green = Safe
- Yellow = Warning
- Red = Critical

### DISPLAY_SCROLLING

Activated through joystick movement.

Allows the user to cycle through individual metrics displayed as enlarged numerical values.

### DISPLAY_RETURNING

Intermediate timeout state.

Maintains the currently selected metric while monitoring for user activity.

After three seconds of inactivity, the display automatically returns to the default bar graph view.

---

## Interrupt-Driven Joystick Driver (`joystick.c` / `joystick.h`)

The joystick subsystem interfaces with a two-axis analog joystick connected to:

- PA0 (X-axis)
- PA1 (Y-axis)

### Features

- ADC1 scan mode
- Continuous conversion mode
- Interrupt-driven sampling
- Automatic overrun recovery
- Axis calibration offsets
- Software deadband filtering

### Noise Suppression

The driver applies configurable centering offsets and deadband thresholds:

```c
JOY_DEADBAND = 15
```

to eliminate:

- Analog noise
- Mechanical centering error
- Phantom navigation events

### Robust ADC Sampling

The joystick subsystem continuously samples both axes using ADC scan mode while leveraging interrupt-driven data acquisition.

Overrun conditions are detected and automatically recovered, ensuring stable operation even under heavy system load.

This implementation provides responsive, non-blocking user input without requiring polling loops inside application code.

---

# 💡 Advanced Implementations Beyond Curriculum

This project required extensive use of manufacturer datasheets and hardware-level analysis to implement functionality normally abstracted by high-level frameworks.

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

- Uses integer-only arithmetic
- Avoids floating-point overhead
- Implements Bosch's datasheet-defined compensation procedure

Resulting measurements are returned with approximately:

```text
±0.01°C resolution
```

while remaining computationally efficient on the Cortex-M4.

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

```text
Cal = trunc(0.04096 / (Current_LSB × Rshunt))
```

### Result

```text
0x0199
```

Writing this value allows the INA219 to:

- Perform current calculations internally
- Reduce MCU computation overhead
- Improve measurement accuracy

---

## 🎨 Shadow-Buffered Matrix Graphics & Custom Typography

The HT16K33 LED matrix controller does not provide native pixel-addressable text rendering.

To overcome this limitation, a custom graphics engine was implemented.

### Custom Fonts

Two compact bitmap font sets were designed:

- 3×5 font for numerical values
- 3×3 font for engineering units

### Shadow Buffer Rendering

```c
uint8_t shadowBuffer[16];
```

Characters are rendered into an off-screen memory buffer before being transmitted to the display.

### Atomic Display Updates

Once rendering is complete:

- The entire 16-byte frame buffer is transmitted over I2C
- Display flicker is eliminated
- Bus traffic is minimized

This approach provides smooth updates while maintaining deterministic rendering behavior.

---

# 📂 Repository Layout

```text
hardware-health-monitor/
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

# 🛠️ Verification & Testing

System performance was validated using a digital logic analyzer and runtime instrumentation techniques.

## Scheduler Timing Analysis

Scheduler timing behavior was validated using GPIO instrumentation and logic analyzer measurements to observe execution intervals and context-switch timing.

## I2C Signal Integrity

Monitored SDA and SCL traffic to verify:

- Sensor polling transactions
- Display update bursts
- Proper start/stop sequencing
- Absence of bus contention
- Reliable timeout recovery behavior

## FSM Validation

Confirmed:

- Correct state transitions during joystick interaction
- Numerical display navigation behavior
- Automatic timeout return after 3000 ms of inactivity
- Restoration of the default bar graph display

---

# Key Learning Outcomes

This project provided practical experience with:

- Bare-metal STM32 development
- ARM Cortex-M exception handling
- PendSV-based context switching
- Register-level peripheral configuration
- I2C protocol implementation
- Interrupt-driven ADC acquisition
- Finite State Machine design
- Sensor calibration algorithms
- Embedded graphics rendering
- Real-time system debugging using logic analyzers

---

# Author

**Jesse Rost**

**Email:** rostj@msoe.edu

**Course:** CPE 2610 – Embedded Systems Design Lab
