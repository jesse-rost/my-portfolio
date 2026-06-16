/**
 * @file        : i2c.h
 * @brief       : Header for i2c
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 12 - I2C
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/14/26
 */

#ifndef I2C_H_
#define I2C_H_
#include <stdint.h>

extern volatile uint8_t i2c_busy;

/**
 * @brief Initializes the I2C peripheral with the specified mode.
 *
 * This function configures the I2C hardware, including clock settings,
 * addressing mode, and enabling the peripheral for communication.
 *
 * @param mode The operating mode for the I2C peripheral.
 *             (e.g., standard mode, fast mode, master/slave configuration)
 */
void i2c_init(uint8_t mode);

/**
 * @brief Writes a sequence of bytes to a specified I2C slave device.
 *
 * This function sends a start condition, transmits the slave address
 * with a write request, and writes multiple bytes of data to the slave.
 * A stop condition is generated after the transmission is complete.
 *
 * @param slaveaddr     The 7-bit address of the target I2C slave device.
 * @param write_length  The number of bytes to be written.
 * @param write_data    Pointer to the buffer containing data to send.
 *
 * @note The function assumes the I2C peripheral has already been initialized.
 * @warning Ensure write_data is valid and write_length > 0 to avoid undefined behavior.
 */
void i2c_write(uint8_t slaveaddr, uint8_t write_length, uint8_t* write_data);


/**
 * @brief Reads a sequence of bytes from a specified I2C slave device.
 *
 * @param slaveaddr     The 7-bit address of the target I2C slave device.
 * @param read_length   The number of bytes to be read.
 * @param read_data     Pointer to the buffer to store received data.
 */
void i2c_read(uint8_t slaveaddr, uint8_t read_length, uint8_t *read_data);

#endif /* I2C_H_ */
