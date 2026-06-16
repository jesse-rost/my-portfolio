/*
 * ina219.c
 *
 *  Created on: Apr 28, 2026
 *      Author: rostj
 */

#include "ina219.h"
#include "i2c.h"

volatile uint16_t g_voltage = 0;
volatile int16_t g_current = 0;

void ina219_init() {

	uint8_t config[3];

	// since we are just using all defaults, we can just write the reset value
	config[0] = INA219_REG_CONFIG;
	config[1] = 0b00111001;
	config[2] = 0b10011111;

	// write the config reg using i2c_write
	// addr is the chip we are talking to, while REG_CONFIG is the reg inside
	// the chip
	i2c_write(INA219_ADDR, 3, config);

	// calculated using formula on data sheet
	// cal = trunc(0.04096 / (Current_LSB * R_Shunt)
	// R_Shunt on my peripheral is 0.1 ohms
	// Current_LSB is chosen to be 0.001 for easier math
	config[0] = INA219_REG_CALIB;
	config[1] = 0x01;   // MSB of 0x0199
	config[2] = 0x99;   // LSB of 0x0199

	// write the calibration reg using i2c_write
	i2c_write(INA219_ADDR, 3, config);

}

uint16_t ina219_read_voltage() {

	uint8_t reg = INA219_REG_BUS;
	uint8_t data[2];
	uint16_t val = 0x0000;

	// write the register pointer
	i2c_write(INA219_ADDR, 1, &reg);

	// read the two bytes back into data
	i2c_read(INA219_ADDR, 2, data);

	// combine two bytes into a 16-bit value
	val |= (data[0] << 8);
	val |= (data[1] << 0);

	// bus voltage is not raw voltage, bits 0-2 are status flags, bits 3-15
	// are actual values, thus we need to shift the value right by 3 and mult by
	// 4 to get the raw voltage before returning.
	val = (val >> 3) * 4;

	return val;
}

int16_t ina219_read_current() {
	uint8_t reg = INA219_REG_CURRENT;
	uint8_t data[2];
	// current can be negative, use signed int
	int16_t val = 0x0000;

	// write the register pointer
	i2c_write(INA219_ADDR, 1, &reg);

	// read the two bytes back into data
	i2c_read(INA219_ADDR, 2, data);

	// combine two bytes into a 16-bit value
	val |= (data[0] << 8);
	val |= (data[1] << 0);

	// current reg has no status flags, thus we can just return the value
	return val;
}

void ina219_task(void) {
while(1){
	g_voltage = ina219_read_voltage();
	g_current = ina219_read_current();
}


}
