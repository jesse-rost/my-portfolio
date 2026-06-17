/**
 * @file        : test.c
 * @brief       : Test file for CPE 2610 Lab 11 - ADXL345 Accelerometer
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 11 - ADXL345 Accelerometer
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/07/26
 */

#include <stdint.h>
#include <stdio.h>
#include <spi_api.h>
#include <delay.h>
#include <regaddr.h>
#include <adxl345.h>

// pa0 for polling interrupts
#define INT1_PIN  (1 << 0)
#define INT1_PORT ((GPIO*)GPIOA_MODER)

/**
 * @brief Initializes PA0 as an input pin for polling
 * the ADXL345 INT1 interrupt signal.
 */
void initINT1(void){
    volatile uint32_t* ahb1enr = (uint32_t*)RCC_AHB1ENR;
    // enable port a
    *ahb1enr |= GPIOAEN_MASK;

    GPIO* const gpioa = (GPIO*)GPIOA_MODER;
    // set pa0 as input
    gpioa->MODER &= ~(3<<(0*2));
    // no pull-up/down
    gpioa->PUPDR &= ~(3<<(0*2));
}

/**
 * @brief Main test loop. Continuously reads X, Y, Z acceleration
 * data from the ADXL345 and prints it to the serial console.
 * Also detects and reports single and double tap events via
 * the interrupt source register.
 */
void runTest(void){
    int16_t x, y, z;
    initINT1();

    while(1){
        ADXL345_ReadXYZ(&x, &y, &z);

        float x_g = x * 0.004f;
        float y_g = y * 0.004f;
        float z_g = z * 0.004f;

        uint8_t src = ADXL345_GetInterrupt();

        printf("\033[2J\033[H");
        printf("adxl345 accelerometer (units: g)\n");
        printf("--------------------------------\n");
        printf("x: %.3f g\n", x_g);
        printf("y: %.3f g\n", y_g);
        printf("z: %.3f g\n", z_g);

        if(src & DOUBLE_TAP){
            printf("\ndouble tap detected!\n");
            delay_ms(1000);
        } else if(src & SINGLE_TAP){
            printf("\nsingle tap detected!\n");
        }

        delay_ms(50);
    }
}
