/**
 * @file        : spi_api.c
 * @brief       : fully built api for spi
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 10 - SPI_API
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 03/31/26
 */


#include <spi_api.h>
// I chose not to use the CMSIS
#include <regaddr.h>


void spi_init(uint8_t mode, uint8_t baud_div){

	volatile uint32_t* ahb1enr = (uint32_t*)RCC_AHB1ENR;
	volatile uint32_t* apb2enr = (uint32_t*)RCC_APB2ENR;

	// enable port A
	*ahb1enr |= GPIOAEN_MASK;

	// enable SPI1
	*apb2enr |= SPI1_EN;

	GPIO* const gpioa = (GPIO*)GPIOA_MODER;

	// clear bits 8-15 (PA4-7)
	gpioa->MODER &= ~(CLEAR_BITS_MSK);

	// set bits 10-15 to alternate function mode
	// set bits 8-9 to output mode
	gpioa->MODER |= (BIT_MODES_MSK);

	// set PA5-7 to use the SPI1 peripheral (AF5)
	gpioa->AFRL |= ((0x5<<20)|(0x5<<24)|(0x5<<28));

	// set PA4 to HIGH, safety feature
	gpioa->ODR |= (1<<4);

	// grab the mode parameter and assign to CPOL and CPHA
	// isolate the bit that corresponds to each and & it with 1
	uint8_t CPOL = (mode>>1) & 0x1;
	uint8_t CPHA = mode & 0x1;

	SPI* const spi = (SPI*)SPI1_BASE;

	// clear CR1 before configuring to prevent stale bits from previous init
	spi->CR1 = 0;

	// set the CPOL bit
	spi->CR1 |= (CPOL<<1);

	// set the CPHA bit
	spi->CR1 |= (CPHA<<0);

	// isolate the first 3 bits from baud_div
	baud_div &= 0b111;

	// set the baud_div to BR control
	spi->CR1 |= (baud_div<<BR);

	// enable the MSTR bit
	spi->CR1 |= MSTR_EN;

	// enable the SSM bit
	spi->CR1 |= SSM_EN;

	// enable the SSI bit
	spi->CR1 |= SSI_EN;
}

int spi_wr(int write_length, uint8_t* write_data, int read_length,
		uint8_t* read_data, int overlap){

	GPIO* const gpioa = (GPIO*)GPIOA_MODER;

	// pull PA4 LOW to begin transaction
	gpioa->ODR &= ~(1<<4);

	SPI* const spi = (SPI*)SPI1_BASE;

	// enable SPI, set SPE bit in CR1
	spi->CR1 |= SPE_EN;

	int totalIterations = write_length + read_length - overlap;

	// counter that tracks the position in read_data buffer
	// since we dont start filling the read_data buffer until overlap
	// we need a SEPARATE variable and cannot use i within the loop
	int r = 0;

	for(int i = 0; i < totalIterations; i++){
		// write only
		if(i < write_length - overlap){
			while(!(spi->SR & (TXE))) {
				// wait until TXE = 1
			}

			spi->DR = write_data[i];

			while(!(spi->SR & (RXNE))){
				// wait until RXNE = 1
			}

			// write causes receive
			// we will always receive a value when we write a value,
			// thus we need to receive that value so that it has a place to go.
			// without this variable there will be an overrun error as whenever
			// we write another variable, this one wont know where to go.
			volatile uint8_t discard = spi->DR;

		} else if((i >= write_length - overlap) && (i < write_length)) {
			// overlap

			while(!(spi->SR & (TXE))) {
				// wait until TXE = 1
			}

			// write the data
			spi->DR = write_data[i];

			while(!(spi->SR & (RXNE))) {
				// wait until RXNE = 1
			}

			// read the buffer
			read_data[r++] = spi->DR;

		} else if(i >= write_length) {
			// read only
			while(!(spi->SR & (TXE))) {
				// wait until TXE = 1
			}

			// in order to read from the buffer, we need to write
			// something to it, even if its a "dummy" variable
			spi->DR = 0x00;

			while(!(spi->SR & (RXNE))) {
				// wait until RXNE = 1
			}

			// now, we can read the buffer
			read_data[r++] = spi->DR;
		}
	}

	while(spi->SR & (BSY)){
		// wait til BSY = 0
	}

	// pull PA4 HIGH to signify transaction end
	gpioa->ODR |= (1<<4);

	// clear SPE
	spi->CR1 &= ~(SPE_EN);

	return 0;
}
