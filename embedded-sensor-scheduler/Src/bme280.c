/**
 * @file        : bme280.c
 * @brief       : filled functions for the temperature sensor
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 */
#include "bme280.h"
#include "i2c.h"

int32_t t_fine;
bme280_calib_t calib;

volatile int32_t g_temp = 0;

static int32_t bme280_compensate_temp(int32_t adc_T);


void bme280_init() {
    uint8_t config[2];
    config[0] = BME280_CTRL_MEAS;
    config[1] = 0b00100011;
    i2c_write(BME280_ADDR, 2, config);

    // read trim data once here
    uint8_t reg = BME280_DIG_T1;
    i2c_write(BME280_ADDR, 1, &reg);
    uint8_t trim[6];
    for (int i = 0; i < 6; i++) {
        i2c_read(BME280_ADDR, 1, &trim[i]);
    }
    calib.dig_T1 = (trim[1] << 8) | trim[0];
    calib.dig_T2 = (trim[3] << 8) | trim[2];
    calib.dig_T3 = (trim[5] << 8) | trim[4];
}

int32_t bme280_read_temp() {
    uint8_t temp_reg = BME280_REG_TEMP;
    i2c_write(BME280_ADDR, 1, &temp_reg);

    uint8_t raw[3];
    for (int i = 0; i < 3; i++) {
        i2c_read(BME280_ADDR, 1, &raw[i]);
    }

    uint32_t adc_T = 0;
    // combine
    adc_T |= ((int32_t)raw[0] << 12);
    adc_T |= ((int32_t)raw[1] << 4);
    adc_T |= ((int32_t)raw[2] >> 4);

    return bme280_compensate_temp(adc_T);
}

static int32_t bme280_compensate_temp(int32_t adc_T) {
	// datasheet compensation formula with my specific variables
	int32_t var1, var2, T;
	var1 = ((((adc_T >> 3) - ((int32_t) calib.dig_T1 << 1)))
			* ((int32_t) calib.dig_T2)) >> 11;
	var2 = (((((adc_T >> 4) - ((int32_t) calib.dig_T1))
			* ((adc_T >> 4) - ((int32_t) calib.dig_T1))) >> 12)
			* ((int32_t) calib.dig_T3)) >> 14;
	t_fine = var1 + var2;
	T = (t_fine * 5 + 128) >> 8;
	return T;
}

void bme280_task(void) {
while(1){
	g_temp = bme280_read_temp();

}

}

