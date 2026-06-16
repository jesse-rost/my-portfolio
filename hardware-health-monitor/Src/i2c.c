/**
 * Experience : I thought that this lab was rather easy to set up the init and
 * not too bad to set up the write function. All the functions intended
 * in this lab do work based on my implementation with a test file that draws
 * the same sort of pattern as the image on the lab manual. Something that I had
 * problems with was getting the display to turn on and display the colors.
 * After messing with different address values for the LED matrix (0x70-0x77)
 * with no progress, I found that since my piezo was connected to the
 * same gpiob port as my SCL cable, that is what was causing the issue as it
 * mustve been messing with the voltage that was being sent to the matrix, even
 * at 5V.
 *
 * @file        : i2c.c
 * @brief       : Source file for i2c filling out the init and write functions
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 12 - I2C
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/14/26
 */

#include "i2c.h"
#include "regaddr.h"
#include "delay.h"

volatile uint8_t i2c_busy = 0;


void i2c_init(uint8_t mode) {

	delay_ms(1);

	volatile uint32_t *ahb1enr = (uint32_t*) RCC_AHB1ENR;
	volatile uint32_t *apb1enr = (uint32_t*) RCC_APB1ENR;

	// enable port B
	*ahb1enr |= GPIOBEN_MASK;

	// enable i2c1 (used for pb8,9)
	*apb1enr |= I2C1EN;

	GPIO *const gpiob = (GPIO*) GPIOB_MODER;
	I2C *const i2c = (I2C*) I2C1_BASE;

	// clear bits 16-19 (pb8,9)
	gpiob->MODER &= ~(0xF << 16);

	// set bits to AF mode (0b1010 -> 0xA)
	gpiob->MODER |= (0xA << 16);

	// clear AFRH bits for PB8 and PB9
	gpiob->AFRH &= ~(0xF << (0 * 4));
	gpiob->AFRH &= ~(0xF << (1 * 4));

	// set PB8 and PB9 to AF4 for I2C1
	gpiob->AFRH |= (0x4 << (0 * 4));
	gpiob->AFRH |= (0x4 << (1 * 4));

	// set pb8,9 to open drain in OTYPER
	gpiob->OTYPER |= (1 << 8);
	gpiob->OTYPER |= (1 << 9);

	// enable internal pull-ups on PB8 and PB9
	gpiob->PUPDR &= ~(0xF << 16);
	gpiob->PUPDR |= (0x5 << 16);

	// set low speed on PB8 and PB9
	gpiob->OSPEEDR &= ~(0xF << 16);

	// software reset using direct assignment
	i2c->CR1 = (1 << 15);
	i2c->CR1 = 0;

	// disable PE before configuring
	i2c->CR1 &= ~(PE_EN);

	// set frequency using direct assignment (16MHz)
	i2c->CR2 = FREQ;

	// clear and set CCR
	i2c->CCR &= ~(0xFFF << 0);
	if (mode == I2C_FAST_MODE) {
		i2c->CCR = 0x0D;
	} else if (mode == I2C_STD_MODE) {
		// std mode, so set ccr to 80 for 50% duty cycle
		i2c->CCR = 0x50;
	}

	// clear and set TRISE
	i2c->TRISE &= ~(0x3F << 0);
	if (mode == I2C_FAST_MODE) {
		i2c->TRISE = 0x05;
	} else if (mode == I2C_STD_MODE) {
		i2c->TRISE = 0x11;
	}

	// enable PE
	i2c->CR1 |= PE_EN;
}

void i2c_write(uint8_t slaveaddr, uint8_t write_length, uint8_t *write_data) {
    I2C *const i2c = (I2C*) I2C1_BASE;
    int count = 0;
    const int TIMEOUT = 10000;

    i2c->SR1 = 0x0000;

    while (i2c->SR2 & I2C_BUSY) {
        if (count++ > TIMEOUT) return;
    }

    i2c->CR1 |= START_GENERATION;
    count = 0;

    while (!(i2c->SR1 & I2C_SB)) {
        if (count++ > TIMEOUT) return;
    }

    i2c->DR = (slaveaddr << 1);
    count = 0;

    while (!(i2c->SR1 & I2C_ADDR)) {
        if (i2c->SR1 & (1 << 10)) {
            i2c->SR1 &= ~(1 << 10);
            i2c->CR1 |= STOP_GENERATION;
            return;
        }
        if (count++ > TIMEOUT) return;
    }

    volatile uint32_t dummy = i2c->SR1;
    dummy = i2c->SR2;
    (void) dummy;

    for (int i = 0; i < write_length; i++) {
        count = 0;
        while (!(i2c->SR1 & I2C_TXE)) {
            if (count++ > TIMEOUT) return;
        }
        i2c->DR = write_data[i];
    }

    count = 0;
    while (!(i2c->SR1 & I2C_BTF)) {
        if (count++ > TIMEOUT) return;
    }

    i2c->CR1 |= STOP_GENERATION;
}

void i2c_read(uint8_t slaveaddr, uint8_t read_length, uint8_t *read_data) {
    I2C *const i2c = (I2C*) I2C1_BASE;
    const int TIMEOUT = 10000;
    int count = 0;

    i2c->SR1 = 0x0000;

    while (i2c->SR2 & I2C_BUSY) {
        if (count++ > TIMEOUT) return;
    }

    i2c->CR1 |= START_GENERATION;
    count = 0;

    while (!(i2c->SR1 & I2C_SB)) {
        if (count++ > TIMEOUT) return;
    }

    i2c->DR = (slaveaddr << 1) | 1;
    count = 0;

    while (!(i2c->SR1 & I2C_ADDR)) {
        if (i2c->SR1 & (1 << 10)) {
            i2c->SR1 &= ~(1 << 10);
            i2c->CR1 |= STOP_GENERATION;
            return;
        }
        if (count++ > TIMEOUT) return;
    }

    if (read_length == 1) {
        i2c->CR1 &= ~(I2C_ACK);
        volatile uint32_t dummy = i2c->SR1;
        dummy = i2c->SR2;
        (void) dummy;

        while (!(i2c->SR1 & I2C_RXNE)) {
            if (count++ > TIMEOUT) return;
        }

        read_data[0] = i2c->DR;
        i2c->CR1 |= STOP_GENERATION;

    } else if (read_length == 2) {
        i2c->CR1 |= (1 << 11);
        i2c->CR1 &= ~(I2C_ACK);
        volatile uint32_t dummy = i2c->SR1;
        dummy = i2c->SR2;
        (void) dummy;

        count = 0;
        while (!(i2c->SR1 & I2C_BTF)) {
            if (count++ > TIMEOUT) return;
        }

        i2c->CR1 |= STOP_GENERATION;
        read_data[0] = i2c->DR;
        read_data[1] = i2c->DR;
        i2c->CR1 &= ~(1 << 11);

    } else if (read_length > 2) {
        i2c->CR1 |= I2C_ACK;
        volatile uint32_t dummy = i2c->SR1;
        dummy = i2c->SR2;
        (void) dummy;

        for (int i = 0; i < read_length; i++) {
            if ((read_length - i) == 2) {
                i2c->CR1 &= ~(I2C_ACK);
            }
            count = 0;
            while (!(i2c->SR1 & I2C_RXNE)) {
                if (count++ > TIMEOUT) return;
            }
            if ((read_length - i) == 1) {
                i2c->CR1 |= STOP_GENERATION;
            }
            read_data[i] = i2c->DR;
        }
    }
}
