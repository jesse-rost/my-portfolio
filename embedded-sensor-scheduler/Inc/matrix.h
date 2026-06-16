/**
 * @file        : matrix.h
 * @brief       : Header for the matrix operations
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 12 - I2C
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/14/26
 */

#ifndef MATRIX_H_
#define MATRIX_H_

#include "i2c.h"
#include <stdint.h>

#define ht16k33_addr 0x70
#define OSCILLATOR 0x21
#define DISPLAY 0x81
#define MAX_BRIGHTNESS 0xEF
#define REG_STARTADDR 0x00
#define UNIT_V 1
#define UNIT_A 0
#define UNIT_C 2
#define UNIT_MA 3

#define COLOR_RED 0
#define COLOR_GREEN  1
#define COLOR_YELLOW 2

// voltage thresholds in mV
#define VGREEN_THRESH 3000
#define VYELLOW_THRESH 2500

// current thresholds in mA
#define CYELLOW_THRESH 50
#define CRED_THRESH 100

// temperature thresholds in 0.01 degrees C
#define TYELLOW_THRESH 4000
#define TRED_THRESH 6000

// 3x5 font - each char is 3 bytes (columns), 5 bits per column
static const uint8_t font3x5[][3] = {
    {0x1F, 0x11, 0x1F}, // '0'
    {0x00, 0x1F, 0x00}, // '1'
    {0x1D, 0x15, 0x17}, // '2'
    {0x11, 0x15, 0x1F}, // '3'
    {0x07, 0x04, 0x1F}, // '4'
    {0x17, 0x15, 0x1D}, // '5'
    {0x1F, 0x15, 0x1D}, // '6'
    {0x01, 0x01, 0x1F}, // '7'
    {0x1F, 0x15, 0x1F}, // '8'
    {0x17, 0x15, 0x1F}, // '9'
    {0x1F, 0x05, 0x1F}, // 'A'
    {0x1F, 0x11, 0x11}, // 'C'
    {0x1F, 0x02, 0x1F}, // 'V' - actually looks like a V
    {0x00, 0x0C, 0x00}, // '.'
    {0x1F, 0x15, 0x17}, // 'G' - for degrees
    {0x1F, 0x01, 0x01}, // 'm' approximation
};
// 3x3 characters for the units
static const uint8_t font3x3[][3] = {
    {0x07, 0x01, 0x07}, // 'V' - two diagonals meeting at bottom
    {0x07, 0x04, 0x07}, // 'A' - arch with crossbar
    {0x07, 0x05, 0x05}, // 'C' - left side open
	{0x07, 0x02, 0x07}, // Index 3: 'm' (approximation for mA)
};

extern uint8_t shadowBuffer[16];

/**
 * @brief Initializes the LED matrix display.
 *
 * This function configures the HT16K33 LED driver over I2C by enabling
 * the internal oscillator, turning on the display, and setting the
 * maximum brightness. It prepares the display for subsequent pixel updates.
 *
 * @note Requires the I2C peripheral to be initialized before calling.
 */
void displayInit(void);

/**
 * @brief Write a 16-byte framebuffer to the display in one I2C transaction.
 * @param buf  Pointer to a 16-byte array (8 rows x 2 bytes: green, red per row)
 */
void displayRefresh(uint8_t *buf);

/**
 * @brief  Displays a selected metric value on the LED matrix.
 *
 *         Formats and renders one of three metrics (voltage, current,
 *         or temperature) as a numeric string on the top portion of
 *         the LED matrix. The corresponding unit symbol is displayed
 *         on the bottom portion. The display color is dynamically
 *         selected based on predefined threshold values for each metric.
 *
 *         - Voltage is displayed in X.X format (e.g., 3.7 V)
 *         - Current is displayed as an integer (e.g., 5 A)
 *         - Temperature is displayed as an integer (e.g., 25 C)
 *
 *         Characters are rendered using a 3x5 font, while units use
 *         a 3x3 font. A decimal point is drawn manually when needed.
 *
 * @param  metric_index  चयन of metric to display:
 *                      0 = Voltage
 *                      1 = Current
 *                      2 = Temperature
 * @param  voltage       Measured voltage in millivolts
 * @param  current       Measured current (scaled per implementation)
 * @param  temp          Measured temperature (scaled, typically x100)
 */
void matrix_display_value(uint8_t metric_index, uint16_t voltage, int16_t current, int32_t temp);

/**
 * @brief  Displays a bar graph of voltage, current, and temperature.
 *
 *         Visualizes all three metrics simultaneously using vertical
 *         bar graphs on the LED matrix. Each metric is assigned a
 *         dedicated column region:
 *
 *         - Voltage:     Rightmost columns
 *         - Current:     Middle columns
 *         - Temperature: Leftmost columns
 *
 *         Each value is scaled to a maximum height of 8 rows. Bars are
 *         filled from bottom to top. The color of each bar is determined
 *         using threshold comparisons:
 *
 *         - Green  = Safe range
 *         - Yellow = Warning range
 *         - Red    = Critical range
 *
 *         Temperature height is capped to prevent overflow beyond
 *         the display limits.
 *
 * @param  voltage   Measured voltage in millivolts
 * @param  current   Measured current (scaled per implementation)
 * @param  temp      Measured temperature (scaled, typically x100)
 */
void matrix_bargraph(uint16_t voltage, int16_t current, int32_t temp);


#endif /* MATRIX_H_ */
