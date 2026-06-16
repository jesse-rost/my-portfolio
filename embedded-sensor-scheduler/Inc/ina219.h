/**
 * @file        : ina219.h
 * @brief       : includes the function prototype for the volt/current sensor
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 */

#ifndef INA219_H_
#define INA219_H_

#include <stdint.h>

// define all the addresses
#define INA219_ADDR         0x40
#define INA219_REG_CONFIG   0x00
#define INA219_REG_SHUNT    0x01
#define INA219_REG_BUS      0x02
#define INA219_REG_POWER    0x03
#define INA219_REG_CURRENT  0x04
#define INA219_REG_CALIB    0x05

extern volatile uint16_t g_voltage;
extern volatile int16_t g_current;

/**
 * @brief  Initializes the INA219 current/power monitor.
 *
 *         Sets up the device over I2C by writing to the configuration
 *         register and loading the calibration register. This prepares
 *         the sensor for voltage and current measurements.
 *
 */
void ina219_init();

/**
 * @brief  Reads the bus voltage from the INA219.
 *
 *         Retrieves the raw bus voltage register value over I2C,
 *         processes it according to the datasheet format, and
 *         returns the measured voltage.
 *
 * @return uint16_t  Measured bus voltage (typically in millivolts,
 *                   depending on implementation scaling).
 */
uint16_t ina219_read_voltage();

/**
 * @brief  Reads the current from the INA219.
 *
 *         Uses the calibrated current register to obtain the measured
 *         current value. The result depends on the calibration value
 *         previously written during initialization.
 *
 * @return int16_t  Measured current (typically in milliamps,
 *                  depending on calibration and scaling).
 */
int16_t ina219_read_current();

/**
 * @brief  Periodic task for updating sensor readings.
 *
 *         Intended to be called in a loop or scheduler. Reads the latest
 *         voltage and current values from the INA219 and updates the
 *         global variables (g_voltage and g_current).
 *
 */
void ina219_task(void);



#endif /* INA219_H_ */
