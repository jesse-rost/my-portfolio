/**
 * @file        : regaddr.h
 * @brief       : Portable Header file containing STM32F411 Addresses and
 * 				  Control Bit Masks
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 8 - Analog Input
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 03/09/26
 */

#ifndef REGADDR_H_
#define REGADDR_H_
#include <stdint.h>

//RCC
#define RCC_AHB1ENR 0x40023830
#define GPIOAEN_MASK (1<<0)
#define GPIOBEN_MASK (1<<1)
#define ADC1EN_MASK  (1<<8)

#define RCC_APB2ENR 0x40023844
#define RCC_APB1ENR 0x40023840
#define USART2EN_MASK (1<<17)

//GPIOA
#define GPIOA_MODER 0x40020000
#define GPIOA_PUPDR 0x4002000c
#define GPIOA_IDR 	0x40020010
#define GPIOA_ODR 	0x40020014
#define GPIOA_AFRL  0x40020020

typedef struct {
	volatile uint32_t MODER;
	volatile uint32_t OTYPER;
	volatile uint32_t OSPEEDR;
	volatile uint32_t PUPDR;
	volatile const uint32_t IDR;
	volatile uint32_t ODR;
	volatile uint32_t BSRR;
	volatile uint32_t LCKR;
	volatile uint32_t AFRL;
	volatile uint32_t AFRH;
}GPIO;

//GPIOB
#define GPIOB_MODER 0x40020400
#define GPIOB_PUPDR 0x4002040c
#define GPIOB_IDR 	0x40020410
#define GPIOB_ODR	0x40020414
#define GPIOB_AFRL  0x40020420
#define GPIOB_AFRH  0x40020424

//UART
#define USART2_SR   0x40004400
#define USART2_DR   0x40004404
#define USART2_BRR  0x40004408
#define USART2_CR1  0x4000440c
#define USART2_CR2  0x40004410
#define USART2_CR3  0x40004414

// CR1 bits
#define UE_MASK (1<<13)
#define TE_MASK (1<<3)
#define RE_MASK (1<<2)

// SR control bits
#define TXE_MASK (1<<7)
#define RXNE_MASK (1<<5)

// TIM bits
#define TIM10_BASE  0x40014400
#define T10_MASK       (1<<17)
#define TIM_CCMR1_PWM1 (0x6 << 4)
#define TIM_CCER_CC1E  (1 << 0)
#define TIM_SR_UIF (1 << 0)

// TIM
// based on tim1 reg map
typedef struct {
	volatile uint32_t CR1;
	volatile uint32_t CR2;
	volatile uint32_t SMCR;
	volatile uint32_t DIER;
	volatile uint32_t SR;
	volatile uint32_t EGR;
	volatile uint32_t CCMR1;
	volatile uint32_t CCMR2;
	volatile uint32_t CCER;
	volatile uint32_t CNT;
	volatile uint32_t PSC;
	volatile uint32_t ARR;
	volatile uint32_t RCR;
	volatile uint32_t CCR1;
	volatile uint32_t CCR2;
	volatile uint32_t CCR3;
	volatile uint32_t CCR4;
	volatile uint32_t BDTR;
	volatile uint32_t DCR;
	volatile uint32_t DMAR;
}TIMER;

// INTERRUPTS and NVIC
// only upto iser2
#define NVIC_BASE 0xE000E100
#define INT_EN_MASK (1<<25)

typedef struct {
	volatile uint32_t ISER0;
	volatile uint32_t ISER1;
	volatile uint32_t ISER2;
}NVIC;

// SYSTICK
#define SYSTICK_BASE 0xE000E010
#define CLKSOURCE (1<<2)
#define TICKINT (1<<1)
#define ENABLE (1<<0)
#define TICKS_PER_MS 16000


typedef struct {
	volatile uint32_t CTRL;
	volatile uint32_t LOAD;
	volatile uint32_t VAL;
	volatile uint32_t CALIB;

}SYSTICK;

// ADC
#define ADC1_BASE    0x40012000
#define SCANEN_MASK  (1<<8)
#define EOCIEN_MASK  (1<<5)
#define OVRIEEN_MASK (1<<26)
#define EOCSEN		 (1<<10)
#define CONTEN		 (1<<1)
#define MAX_CYCLES	 (0x7)
#define ADC_INT		 (1<<18)
#define ADCEN_MASK	 (1<<0)
#define SWSTART		 (1<<30)
#define EOC	 		 (1<<1)
#define OVR			 (1<<5)


typedef struct {
	volatile uint32_t SR;
	volatile uint32_t CR1;
	volatile uint32_t CR2;
	volatile uint32_t SMPR1;
	volatile uint32_t SMPR2;
	volatile uint32_t JOFR1;
	volatile uint32_t JOFR2;
	volatile uint32_t JOFR3;
	volatile uint32_t JOFR4;
	volatile uint32_t HTR;
	volatile uint32_t LTR;
	volatile uint32_t SQR1;
	volatile uint32_t SQR2;
	volatile uint32_t SQR3;
	volatile uint32_t JSQR;
	volatile uint32_t JDR1;
	volatile uint32_t JDR2;
	volatile uint32_t JDR3;
	volatile uint32_t JDR4;
	volatile uint32_t DR;
}ADC;


// SPI
#define CLEAR_BITS_MSK	 (0xFF<<8)
#define SPI1_BASE		 (0x40013000)
#define SPI1_EN			 (1<<12)
#define BIT_MODES_MSK	 (0xA9<<8)
#define MSTR_EN			 (1<<2)
#define SSM_EN			 (1<<9)
#define SSI_EN			 (1<<8)
#define SPE_EN			 (1<<6)
#define BR 				 3     //Bit 3 of CR1
#define CP 				 0     //Bit 0 of CR1
#define BSY 			(1<<7)
#define TXE 			(1<<1)
#define RXNE 			(1<<0)
#define SPE 			(1<<6)
#define SSOE 			(1<<2)



typedef struct {
	volatile uint32_t CR1;
	volatile uint32_t CR2;
	volatile uint32_t SR;
	volatile uint32_t DR;
	volatile uint32_t CRCPR;
	volatile uint32_t RXCRCR;
	volatile uint32_t TXCRCR;
	volatile uint32_t I2SCFGR;
	volatile uint32_t I2SPR;
}SPI;

// I2C
#define I2C1EN (1<<21)
#define I2C1_BASE 0x40005400
#define PE_EN (1<<0)
#define CLKCTL (0x0D << 0)
#define FREQ (0x10 << 0)
#define TRISE_VAL (0x06 << 0)
#define START_GENERATION (1<<8)
#define I2C_SB (1<<0)
#define I2C_ADDR (1<<1)
#define I2C_TXE (1<<7)
#define I2C_BTF (1<<2)
#define STOP_GENERATION (1<<9)
#define I2C_BUSY (1<<1)
#define I2C_FAST_MODE 1
#define I2C_STD_MODE 0
#define I2C_RXNE (1<<6) // I2C SR1
#define I2C_ACK (1<<10) //I2C CR1


typedef struct {
	volatile uint32_t CR1;
	volatile uint32_t CR2;
	volatile uint32_t OAR1;
	volatile uint32_t OAR2;
	volatile uint32_t DR;
	volatile uint32_t SR1;
	volatile uint32_t SR2;
	volatile uint32_t CCR;
	volatile uint32_t TRISE;
	volatile uint32_t FLTR;
}I2C;

// INA219

// make use of default values for init
#define INA219_BVR  (1<<13)
#define INA219_PGA  (0x3<<11)
#define INA219_ADC  (0x3<<3)
#define INA219_MODE (0x7<<0)



#endif /* REGADDR_H_ */
