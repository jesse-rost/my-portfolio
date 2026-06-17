/**
 * @file        : test.h
 * @brief       : Test functions for ADXL345 accelerometer demo
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 11 - ADXL345 Accelerometer
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/07/26
 */

#ifndef TEST_H_
#define TEST_H_

/**
 * @brief Initializes PA0 as a GPIO input for polling the ADXL345 INT1 pin.
 *
 * Enables GPIOA clock, configures PA0 as a floating input with no
 * pull-up or pull-down resistor.
 */
void initINT1(void);

/**
 * @brief Runs the ADXL345 accelerometer demo application.
 *
 * Continuously reads X, Y, and Z acceleration values from the ADXL345
 * over SPI and prints them to the serial console in units of g.
 * Also polls the INT_SOURCE register to detect and display single
 * tap and double tap events.
 *
 * Output format:
 *   adxl345 accelerometer (units: g)
 *   --------------------------------
 *   x: %.3f g
 *   y: %.3f g
 *   z: %.3f g
 *   single tap detected!  (when single tap occurs)
 *   double tap detected!  (when double tap occurs)
 *
 * This function never returns.
 */
void runTest(void);

#endif /* TEST_H_ */
