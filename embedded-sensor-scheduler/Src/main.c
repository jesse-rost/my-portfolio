/**
 * @file        : main.c
 * @brief       Entry point for round-robin scheduled sensor display system.
 *
 *              Initializes hardware peripherals (I2C, joystick, sensors,
 *              display) and configures a cooperative round-robin task
 *              scheduler. The system continuously reads sensor data from
 *              INA219 and BME280 and updates the LED matrix display.
 *
 *              A single periodic task is used to handle sensor acquisition
 *              and display updates in a continuous loop.
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 */

#include <stdint.h>
#include "i2c.h"
#include "joystick.h"
#include "matrix.h"
#include "ina219.h"
#include "bme280.h"
#include "delay.h"
#include "roundRobin.h"
#include "display_task.h"
#include "regaddr.h"


void sensor_display_task(void);

/**
 * @brief  System entry point.
 *
 *         Initializes system peripherals, sensors, display hardware,
 *         and the round-robin task scheduler. Creates the main sensor
 *         display task and starts the scheduler.
 *
 * @note   Execution does not return after scheduler initialization.
 */
int main(void) {
    systick_init();
    i2c_init(I2C_STD_MODE);
    joy_init();
    displayInit();
    ina219_init();
    bme280_init();

    init_tasker(2, 100);
    init_task(1, 512, sensor_display_task, 100);

    for(;;);
}

/**
 * @brief  Main sensor acquisition and display update task.
 *
 *         Continuously reads sensor values from INA219 (voltage/current)
 *         and BME280 (temperature), then updates the display system
 *         using the display state machine.
 *
 *         Includes small delays between sensor reads to prevent I2C
 *         bus saturation and reduce noise from rapid polling.
 *
 *         Also controls display refresh rate to balance responsiveness
 *         and stability.
 */
void sensor_display_task(void) {
    while(1) {
        g_voltage = ina219_read_voltage();
        delay_ms(10);
        g_current = ina219_read_current();
        delay_ms(10);
        g_temp = bme280_read_temp();
        delay_ms(10);
        display_task();
        delay_ms(150);  // controls scroll speed and prevents I2C hammering
    }
}
