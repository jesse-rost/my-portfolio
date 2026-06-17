/*
 * @file        : adxl345.h
 * @brief       : Header file for the ADXL345 accelerometer API
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 11 - ADXL345 Accelerometer
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/07/26
 */

#ifndef ADXL345_H_
#define ADXL345_H_

/* --- Register Addresses --- */
#define DEVID       0x00  // Device ID
#define THRESH_TAP  0x1D  // Tap threshold
#define DUR         0x21  // Tap duration
#define Latent      0x22  // Tap latency
#define Window      0x23  // Tap window
#define TAP_AXES    0x2A  // Axis control for tap detection
#define INT_ENABLE  0x2E  // Interrupt enable control
#define INT_MAP     0x2F  // Interrupt mapping to INT1/INT2
#define INT_SOURCE  0x30  // Interrupt source (read to clear)
#define DATA_FORMAT 0x31  // Data format control
#define FIFO_CTL    0x38  // FIFO control
#define FIFO_STATUS 0x39  // FIFO status
#define DATAX0      0x32  // X-axis data low byte
#define DATAX1      0x33  // X-axis data high byte
#define DATAY0      0x34  // Y-axis data low byte
#define DATAY1      0x35  // Y-axis data high byte
#define DATAZ0      0x36  // Z-axis data low byte
#define DATAZ1      0x37  // Z-axis data high byte
#define POWER_CTL   0x2D  // Power-saving features control

/* --- Tap Configuration ---
 * TAP_THRESH : minimum acceleration to register a tap (62.5 mg/LSB)
 * TAP_DUR    : maximum time a tap can last to be valid (625 us/LSB)
 * TAP_LATENT : wait time between first and second tap (1.25 ms/LSB)
 * TAP_WINDOW : time window after latency for second tap (1.25 ms/LSB)
 */
#define TAP_THRESH  0x40  // 0.5g threshold - easy to trigger
#define TAP_DUR     0x20  // ~50ms max tap duration
#define TAP_LATENT  0x20  // ~40ms latency between taps
#define TAP_WINDOW  0xFF  // maximum window for second tap

/* --- TAP_AXES Register Bits --- */
#define TAP_X_EN    (1<<2)  // Enable tap detection on X axis
#define TAP_Y_EN    (1<<1)  // Enable tap detection on Y axis
#define TAP_Z_EN    (1<<0)  // Enable tap detection on Z axis
#define SUPPRESS    (1<<3)  // Suppress single tap during double tap window

/* --- INT_SOURCE / INT_ENABLE Bits --- */
#define SINGLE_TAP  (1<<6)  // Single tap interrupt bit
#define DOUBLE_TAP  (1<<5)  // Double tap interrupt bit

/* --- DATA_FORMAT Register Bits --- */
#define FULL_RES    (1<<3)      // Full resolution mode
#define RANGE       (0b00<<0)   // +/- 2g range (recommended by Rothe)

/* --- POWER_CTL Register Bits --- */
#define MEASURE     (1<<3)  // Set to wake device and begin sampling



/* --- Function Prototypes --- */

/**
 * @brief Initializes the ADXL345 accelerometer.
 * Configures data format, FIFO, tap detection settings,
 * interrupt enables, and puts the device into measure mode.
 */
void ADXL345_init();

/**
 * @brief Writes a value to a register on the ADXL345.
 * @param reg  Register address to write to.
 * @param val  Value to write.
 */
void ADXL345_WriteReg(uint8_t reg, uint8_t val);

/**
 * @brief Reads a single byte from a register on the ADXL345.
 * @param reg  Register address to read from.
 * @return     Byte read from the register.
 */
uint8_t ADXL345_ReadReg(uint8_t reg);

/**
 * @brief Reads X, Y, and Z acceleration values from the ADXL345.
 * Uses multi-byte SPI read starting at DATAX0.
 * @param x  Pointer to store raw X acceleration (signed 16-bit).
 * @param y  Pointer to store raw Y acceleration (signed 16-bit).
 * @param z  Pointer to store raw Z acceleration (signed 16-bit).
 */
void ADXL345_ReadXYZ(int16_t *x, int16_t *y, int16_t *z);

/**
 * @brief Reads and clears the INT_SOURCE register.
 * Must be called after an interrupt event to clear the flag.
 * @return  Byte containing interrupt source bits.
 */
uint8_t ADXL345_GetInterrupt(void);

#endif /* ADXL345_H_ */
