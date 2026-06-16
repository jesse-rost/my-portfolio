/**
 * @file        : joystick.c
 * @brief       : API analog joystick interface via ADC
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 8 - Analog Input
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 03/09/26
 */

#include "regaddr.h"
#include "joystick.h"
#include <stdlib.h>

// use static flag to track which channel finished
static int expectingX = 1;
static uint32_t rawX = 0;
static uint32_t rawY = 0;

void joy_init(){
	volatile uint32_t* ahb1enr = (uint32_t*)RCC_AHB1ENR;
	volatile uint32_t* apb2enr = (uint32_t*)RCC_APB2ENR;

	// enable port A
	*ahb1enr |= GPIOAEN_MASK;

	// enable ADC1
	*apb2enr |= ADC1EN_MASK;

	GPIO* const gpioa = (GPIO*)GPIOA_MODER;

	// clear bits 0-3 (pins 0, 1)
	gpioa->MODER &= ~(0xF << 0);

	// set those bits to '11' (Analog Mode)
	gpioa->MODER |= (0xF << 0);

	// our board doesnt use adc2 or adc3
	// therefore adc1 is all we can use
	ADC* const adc = (ADC*)ADC1_BASE;

	// set the scan enable mask
	// scan tells the ADC to work through the sequence automatically
	adc->CR1 |= SCANEN_MASK;

	// set the eocie enable mask
	// enables the interrupt so the IQR handler gets called for each conversion
	adc->CR1 |= EOCIEN_MASK;

	// set the ovrie mask
	// enables overrun interrupt to detect and recover if ISR falls behing
	adc->CR1 |= OVRIEEN_MASK;

	// set the eocs enable bit
	// makes the EOC (and the interrupt) fire after each conversion so X
	// and Y are denoted as seperate values
	adc->CR2 |= EOCSEN;

	// set the continuous enable bit
	// keeps the sequence looping forever, no need to manually restart
	adc->CR2 |= CONTEN;

	// enable ADC, bit 0, ADON
	// turns on peripheral interrupt
	adc->CR2 |= ADCEN_MASK;

	// set the sample time to 480 cycles on channel 0
	// channel 0 is connected to PA0 (X-axis)

	// clear bits 0-2
	adc->SMPR2 &= ~(MAX_CYCLES<<0);
	// set bits to 111 (480 cycles)
	adc->SMPR2 |= (MAX_CYCLES<<0);

	// set the sample time to 480 cycles on channel 1
	// channel 1 is connected to PA1 (Y-axis)

	// clear bits 3-5
	adc->SMPR2 &= ~(MAX_CYCLES<<3);
	// set bits to 111 (480 cycles)
	adc->SMPR2 |= (MAX_CYCLES<<3);

	// set sequence length to 2 conversions per sequence, one for x, one for y

	// clear bits 20-23
	adc->SQR1 &= ~(0xF<<20);
	// 0001 is what needs to be mapped to bits 20-23
	adc->SQR1 |= (0x01<<20);

	// setup SQ1 and SQ2 to the proper channel

	// clear bits 0-4
	adc->SQR3 &= ~(0x1F<<0);
	// SQ1 = ch0
	// we will convert the X-axis first
	adc->SQR3 |= (0<<0);

	// clear bits 5-9
	adc->SQR3 &= ~(0x1F<<5);
	// SQ2 = ch1
	// we will convert hte Y-axis second
	adc->SQR3 |= (1<<5);

	NVIC* const nvic = (NVIC*)NVIC_BASE;

	// enable the ADC interrupt in nvic. tells CPU to listen for interrupt
	// ISER0 is used because ADC interrupt is bit 18
	nvic->ISER0 |= ADC_INT;

	// start conversion of reg channels
	adc->CR2 |= SWSTART;
}

int16_t joy_getX() {
	// shifts the number line 0->4096 to -2048->2048
    int16_t val = (int16_t)rawX - 2048 + JOY_X_OFFSET;

    // check for deadband
    if (abs(val) < JOY_DEADBAND){
    	return 0;
    }
    return val;
}

int16_t joy_getY() {
	// shifts the number line 0->4096 to -2048->2048
    int16_t val = (int16_t)rawY - 2048 + JOY_Y_OFFSET;

    // check for deadband
    if (abs(val) < JOY_DEADBAND){
    	return 0;
    }
    return val;
}

joyPosition joy_getXY(){
	// create a new struct
	joyPosition pos;

	// set the variables in the struct to rawX and rawY
	pos.x = joy_getX();
	pos.y = joy_getY();

	// return the struct
	return pos;
}

void ADC_IRQHandler(void) {
    ADC* const adc = (ADC*)ADC1_BASE;

    // check if the EOC bit is set
    if (adc->SR & EOC) {
        if (expectingX) {
            // read DR into rawX
        	rawX = adc->DR;
            // set expectingX to 0
        	expectingX = 0;
        } else {
            // read DR into rawY
        	rawY = adc->DR;
            // set expectingX to 1
        	expectingX = 1;
        }
    }

    // check if the OVR bit is set
    if (adc->SR & OVR) {
        // clear the OVR flag
    	adc->SR &= ~(OVR);
        // stop ADC (clear ADON)
		adc->CR2 &= ~(ADCEN_MASK);
        // reinitialize
		expectingX = 1;
		joy_init();
    }
}
