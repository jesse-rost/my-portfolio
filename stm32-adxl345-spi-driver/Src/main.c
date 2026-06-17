/**
 * Experience:
 * I thought that this lab was particularly more difficult than previous labs.
 * The most confusing part was figuring out the SPI read/write/overlap logic
 * and getting the ADXL345 tap detection tuned correctly. Initialization was
 * straightforward but debugging with the logic analyzer took some getting
 * used to. The biggest issue I ran into was forgetting to call systick_init()
 * before runTest(), which caused delay_ms() to hang and made the loop appear
 * to only run once. With repetition, these debugging skills will become easier
 * to apply quickly.
 *
 * @file        : main.c
 * @brief       : Entry point for the ADXL345 accelerometer application
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 11 - ADXL345 Accelerometer
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/07/26
 *
 * Algorithm:
 * 1. Initialize USART2 for serial console output.
 * 2. Initialize SysTick timer for millisecond delays.
 * 3. Initialize SPI1 peripheral in mode 0.
 * 4. Initialize ADXL345 accelerometer with tap detection settings.
 * 5. Call runTest() which loops indefinitely, printing X, Y, and Z
 *    accelerations to the serial console and detecting tap events.
 */

#include <stdint.h>
#include <stdio.h>

#include "regaddr.h"
#include "delay.h"
#include "uart.h"
#include "test.h"
#include "spi_api.h"
#include "adxl345.h"

/**
 * @brief Entry point for the ADXL345 accelerometer application.
 * Initializes USART2, SysTick, SPI1, and the ADXL345 accelerometer,
 * then calls runTest() to begin printing accelerometer data and
 * detecting tap events to the serial console. Never returns.
 * @return int Required by C standard but never reached.
 */
int main(void) {
    initUsart2();
    systick_init();

    spi_init(0, 0);

    ADXL345_init();

    runTest();
}
