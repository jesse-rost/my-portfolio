/**
 * @file        : spi_api.h
 * @brief       : api header file holding necessary
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 10 - SPI_API
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 03/31/26
 */

#ifndef SPI_API_H_
#define SPI_API_H_

#include <stdint.h>

#define SPI_SCK_PIN  5
#define SPI_MISO_PIN 6
#define SPI_MOSI_PIN 7
#define SPI_SS_PIN   4

/**
 * @brief Initializes the SPI1 peripheral for master mode operation.
 *
 * Enables clocks for GPIOA and SPI1, configures PA5-PA7 as alternate
 * function pins for SCK, MISO, and MOSI respectively, and configures
 * PA4 as a GPIO output for software slave select. Sets up SPI1 CR1
 * with the specified mode and baud rate divisor.
 *
 * @param mode     SPI mode (0-3). Encodes CPOL and CPHA:
 *                 bit1 = CPOL, bit0 = CPHA
 * @param baud_div Baud rate divisor (0-7). Maps to BR[2:0] in CR1.
 *                 0 = fPCLK/2 (fastest), 7 = fPCLK/256 (slowest)
 */
void spi_init(uint8_t mode, uint8_t baud_div);

/**
 * @brief Performs a SPI write and/or read transaction with optional overlap.
 *
 * Asserts slave select (PA4 LOW), enables SPI, then executes three phases:
 *   1. Write-only:  sends write_data bytes, discards received bytes
 *   2. Overlap:     sends write_data bytes and captures received bytes
 *   3. Read-only:   sends dummy 0x00 bytes and captures received bytes
 *
 * Waits for BSY to clear before deasserting slave select and disabling SPI.
 *
 * @param write_length  Number of bytes to write. 0 for read-only.
 * @param write_data    Pointer to buffer of bytes to transmit. NULL if
 *                      write_length is 0.
 * @param read_length   Number of bytes to read. 0 for write-only.
 * @param read_data     Pointer to buffer to store received bytes.
 * @param overlap       Number of bytes where write and read occur
 *                      simultaneously. Must not exceed write_length
 *                      or read_length.
 * @return              0 on success.
 */
int spi_wr(int write_length, uint8_t* write_data, int read_length,
		uint8_t* read_data, int overlap);

#endif /* SPI_API_H_ */
