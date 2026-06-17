# STM32 Bare-Metal SPI & ADXL345 Accelerometer Driver

A high-performance, register-level SPI master driver and layered ADXL345 accelerometer client application developed for the ARM Cortex-M4 microcontroller (STM32F411). This project bypasses hardware abstraction layers (HAL) to interface directly with memory-mapped peripheral registers, illustrating raw serial bus communication, timing analysis, and hardware interrupt-line polling.

---

# 🚀 Architectural Overview

The driver architecture uses a layered hardware-access model. This design separates generic SPI bus operations from device-specific register manipulation, enabling the SPI driver to act as an abstract controller for any synchronous serial peripheral.

```text
┌─────────────────────────────────────────────────────────┐
│               Application Layer (test.c)               │
│   - Converts Raw Signed 16-Bit Values to g-Force Units │
│   - Polls Physical PA0 Line for Real-Time Tap Events   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│          Device-Specific Driver (adxl345.c)            │
│   - Restores Standby FSM Prior to Calibration          │
│   - Atomic Multi-Byte Burst Reads (DATAX0 to DATAZ1)   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│             Generic Bus Driver (spi_api.c)             │
│   - Motorola SPI Bus Arbiter (Modes 0-3)              │
│   - Software Slave Select Management (PA4 Active-LOW) │
└─────────────────────────────────────────────────────────┘
```

---

# 🛠️ Software & Peripheral Breakdown

## Master SPI Peripheral Driver (`spi_api.c` / `spi_api.h`)

The SPI API manages low-level clock and pin properties through direct register manipulation. It supports standard Motorola SPI polarity (CPOL) and phase (CPHA) configurations while handling master-mode data transfers over a shared serial bus.

### SPI Master Initialization

The `spi_init()` function:

- Configures PA5 (SCK), PA6 (MISO), and PA7 (MOSI) for Alternate Function mode (AF5).
- Configures PA4 as a software-controlled Slave Select output.
- Enables SPI1 clocks.
- Configures SPI mode (0–3).
- Sets baud rate divisors and master-mode operation.

```c
void spi_init(uint8_t mode, uint8_t baud_div) {
    volatile uint32_t *ahb1enr = (uint32_t*) RCC_AHB1ENR;
    volatile uint32_t *apb2enr = (uint32_t*) RCC_APB2ENR;

    *ahb1enr |= GPIOAEN_MASK;
    *apb2enr |= SPI1_EN;

    GPIO* const gpioa = (GPIO*) GPIOA_MODER;

    gpioa->MODER &= ~(CLEAR_BITS_MSK);
    gpioa->MODER |= (BIT_MODES_MSK);

    gpioa->AFRL &= ~((0xF << 20) | (0xF << 24) | (0xF << 28));
    gpioa->AFRL |= ((0x5 << 20) | (0x5 << 24) | (0x5 << 28));

    gpioa->ODR |= (1 << 4);

    uint8_t CPOL = (mode >> 1) & 0x1;
    uint8_t CPHA = mode & 0x1;

    SPI* const spi = (SPI*) SPI1_BASE;

    spi->CR1 = 0;
    spi->CR1 |= (CPOL << 1) | (CPHA << 0);
    spi->CR1 |= ((baud_div & 0x7) << BR);
    spi->CR1 |= MSTR_EN | SSM_EN | SSI_EN;
}
```

### Three-Phase Transaction Engine

To prevent hardware overrun (`OVR`) faults and provide flexible full-duplex communication, the SPI driver implements a three-phase transaction engine.

#### Phase 1: Write-Only

- Transmit command bytes.
- Discard incoming shift-register data.
- Clear RXNE to prevent overrun conditions.

#### Phase 2: Overlap

- Simultaneously transmit and receive data.
- Supports command/response style peripherals.

#### Phase 3: Read-Only

- Generate clock edges using dummy writes (`0x00`).
- Capture incoming slave data.

```c
int spi_wr(int write_length,
           uint8_t* write_data,
           int read_length,
           uint8_t* read_data,
           int overlap)
{
    ...
}
```

### Bus Safety

Before releasing the bus:

```c
while (spi->SR & BSY);
```

ensures the final SPI transaction has completely exited the shift register before deasserting Slave Select.

---

## Device-Specific Driver (`adxl345.c` / `adxl345.h`)

The ADXL345 client driver builds on top of the generic SPI engine and manages sensor-specific register interactions.

### Initialization Features

- Restores standby mode before configuration.
- Programs tap-detection registers.
- Configures measurement mode.
- Enables Full-Resolution output mode.

---

### Multi-Byte Burst Reads

Reading individual axis registers separately risks data shearing if the sensor updates during acquisition.

To guarantee atomic reads, the driver performs a six-byte burst transaction beginning at `DATAX0`.

The command byte is assembled using:

- Bit 7 = Read
- Bit 6 = Multi-byte
- Bits 5:0 = Register Address

```text
cmd = (1 << 7) | (1 << 6) | (DATAX0 & 0x3F)
```

```c
void ADXL345_ReadXYZ(int16_t *x,
                     int16_t *y,
                     int16_t *z)
{
    uint8_t cmd = (1 << 7) |
                  (1 << 6) |
                  (DATAX0 & 0x3F);

    uint8_t buf[6];

    spi_wr(1, &cmd, 6, buf, 0);

    *x = (int16_t)((buf[1] << 8) | buf[0]);
    *y = (int16_t)((buf[3] << 8) | buf[2]);
    *z = (int16_t)((buf[5] << 8) | buf[4]);
}
```

### Benefits

- Single transaction
- Consistent axis sampling
- No inter-axis timing skew
- Reduced bus overhead

---

# 📂 File Architecture

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

### File Responsibilities

| File | Purpose |
|--------|----------|
| `spi_api.c` | Motorola SPI master implementation |
| `adxl345.c` | Sensor configuration and burst-read logic |
| `test.c` | Accelerometer processing and tap detection |
| `delay.c` | SysTick timing utilities |
| `uart.c` | USART2 console output |
| `main.c` | Hardware initialization and entry point |
| `syscalls.c` | Newlib syscall stubs |
| `sysmem.c` | Heap and stack memory management |

---

# 🔬 Hardware Testing & Waveform Analysis

System operation was verified using a digital logic analyzer.

## High-Speed Loopback Analysis

Using:

```text
PCLK / 2
Baud Divisor = 0
```

captured waveforms showed small gaps between consecutive bytes.

These gaps correspond to firmware polling overhead while checking:

- TXE (Transmit Buffer Empty)
- RXNE (Receive Buffer Not Empty)

rather than limitations of the SPI peripheral itself.

---

## MISO Diagnostic Integrity Testing

### MISO Grounded

Grounding the MISO line produced:

```text
[0, 0, 0, 0]
```

confirming reliable low-state reception.

### MISO Tied to 3.3V

Connecting MISO directly to VCC produced:

```text
[255, 255, 255, 255]
```

confirming stable high-state detection.

---

## Calibrated g-Force Scaling

Raw signed 16-bit measurements are converted into physical acceleration values using the ADXL345 Full-Resolution scale factor:

```text
4 mg/LSB
```

Conversion:

```text
a_axis = raw_register × 0.004 g
```

This produces calibrated acceleration values expressed directly in units of gravitational acceleration (`g`).

---

# Key Learning Outcomes

This project provided practical experience with:

- Bare-metal STM32 development
- Register-level SPI peripheral configuration
- Motorola SPI protocol implementation
- Software-controlled chip select management
- Full-duplex serial communication
- Multi-byte burst sensor transactions
- Hardware timing analysis using logic analyzers
- Polling-based hardware event detection
- Accelerometer calibration and scaling
- Layered embedded driver architecture

---

# Author

**Jesse Rost**

**Email:** rostj@msoe.edu

**Course:** CPE 2610 – Embedded Systems Design Lab
