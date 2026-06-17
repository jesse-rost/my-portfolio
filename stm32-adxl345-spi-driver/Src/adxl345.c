/*
 * @file        : adxl345.c
 * @brief       : ADXL345 accelerometer driver implementation
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 11 - ADXL345 Accelerometer
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/07/26
 */

#include <spi_api.h>
#include <adxl345.h>
#include <stdlib.h>

// forward declarations for init
void ADXL345_WriteReg(uint8_t reg, uint8_t val);
uint8_t ADXL345_ReadReg(uint8_t reg);
uint8_t ADXL345_GetInterrupt(void);

void ADXL345_init(){
		// put device in standby before configuring - required before changing
		// settings
	    ADXL345_WriteReg(POWER_CTL, 0x00);

	    // set FULL_RES mode and ±16g range in DATA_FORMAT register
	    ADXL345_WriteReg(DATA_FORMAT, FULL_RES | RANGE);

	    // set FIFO to bypass mode - no buffering, read data directly
	    ADXL345_WriteReg(FIFO_CTL, 0x00);

	    // set minimum force required to trigger a tap
	    ADXL345_WriteReg(THRESH_TAP, TAP_THRESH);

	    // set max time a tap can last to be considered valid
	    ADXL345_WriteReg(DUR, TAP_DUR);

	    // set wait time between first and second tap for double tap
	    ADXL345_WriteReg(Latent, TAP_LATENT);

	    // set time window after latency in which second tap must occur
	    ADXL345_WriteReg(Window, TAP_WINDOW);

	    // enable tap detection on X, Y, and Z axes
	    // SUPPRESS bit prevents single tap from firing during the dt window
	    ADXL345_WriteReg(TAP_AXES, (SUPPRESS | TAP_X_EN | TAP_Y_EN | TAP_Z_EN));

	    // enable SINGLE_TAP and DOUBLE_TAP interrupts
	    ADXL345_WriteReg(INT_ENABLE, (SINGLE_TAP | DOUBLE_TAP));

	    // route all interrupts to INT1 pin (0x00 = all to INT1)
	    ADXL345_WriteReg(INT_MAP, 0x00);

	    // set MEASURE bit to wake device up and start sampling
	    ADXL345_WriteReg(POWER_CTL, MEASURE);

	    ADXL345_GetInterrupt();
}

void ADXL345_ReadXYZ(int16_t *x, int16_t *y, int16_t *z){

	// Bit  7 - 0 = Write, 1 = Read
	// Bit  6 - 0 = Single byte, 1 = Multi-byte
	// Bits 5-0 — the register address

	uint8_t cmd = (1 << 7) | (1 << 6) | (DATAX0 & 0x3F);

	// create a 6 byte buffer
	uint8_t buf[6];

	// read all 6 bytes
	spi_wr(1, &cmd, 6, buf, 0);

	// combine each pair
	*x = (int16_t)(buf[1] << 8 | buf[0]);
	*y = (int16_t)(buf[3] << 8 | buf[2]);
	*z = (int16_t)(buf[5] << 8 | buf[4]);
}

uint8_t ADXL345_GetInterrupt(void){
	// create a variable to store the interrupt source register value
	uint8_t result;

	// read INT_SOURCE register - this also clears the interrupt flag on the ADXL345
	result = ADXL345_ReadReg(INT_SOURCE);

	// return the byte so caller can check which interrupt fired (SINGLE_TAP or DOUBLE_TAP)
	return result;
}

void ADXL345_WriteReg(uint8_t reg, uint8_t val){

	// Bit  7 - 0 = Write, 1 = Read
	// Bit  6 - 0 = Single byte, 1 = Multi-byte
	// Bits 5-0 — the register address

	uint8_t cmd = (0 << 7) | (0 << 6) | (reg & 0x3F);

	// create a buffer variable
	uint8_t buf[2] = {cmd, val};

	// write the buffer
	spi_wr(2, buf, 0, NULL, 0);
}

uint8_t ADXL345_ReadReg(uint8_t reg){
	// Bit  7 - 0 = Write, 1 = Read
	// Bit  6 - 0 = Single byte, 1 = Multi-byte
	// Bits 5-0 — the register address

	uint8_t cmd = (1 << 7) | (0 << 6) | (reg & 0x3F);

	// create a result variable
	uint8_t result;

	// write cmd and read the result
	spi_wr(1, &cmd, 1, &result, 0);

	// return the result
	return result;

}
