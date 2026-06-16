/**
 * @file        : bme280.h
 * @brief       : includes the function prototype for the temp sensor
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 */

#include "stdint.h"

#ifndef BME280_H_
#define BME280_H_

#define BME280_ADDR       0x76
#define BME280_CTRL_MEAS  0xF4

// trim registers for temperature
#define BME280_DIG_T1     0x88
#define BME280_DIG_T2     0x8A
#define BME280_DIG_T3     0x8C

// necessary for compensation formula provided through the datasheet
#define BME280_REG_TEMP   0xFA

extern int32_t t_fine;
extern volatile int32_t g_temp;


// struct creation to hold trim values once they are read out
typedef struct {
    uint16_t dig_T1;
    int16_t  dig_T2;
    int16_t  dig_T3;
} bme280_calib_t;


/**
 * @brief  Initializes the BME280 sensor over I2C.
 *         Configures the control measurement register and reads
 *         the factory trim calibration values into the global
 *         calibration struct for use in the compensation formula.
 */
void bme280_init();

/**
 * @brief  FreeRTOS task that periodically reads the BME280 temperature.
 *         Calls bme280_read_temp() on a set interval and stores the
 *         compensated result in the global variable g_temp.
 */
void bme280_task(void);

/**
 * @brief  Reads the raw temperature register from the BME280 and applies
 *         the datasheet compensation formula using the stored trim values.
 *
 * @return Compensated temperature in degrees Celsius scaled by 100
 *         (e.g. 2350 = 23.50°C). Also updates the global t_fine value
 *         used for humidity and pressure compensation.
 */
int32_t bme280_read_temp(void);


#endif /* BME280_H_ */
