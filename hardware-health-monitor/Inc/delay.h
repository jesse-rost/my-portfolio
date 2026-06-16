/**
 * @file        : delay.h
 * @brief       : includes the function prototype for the delay function
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 3 - Buttons and LEDS
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 02/10/26
 */

#ifndef DELAY_H_
#define DELAY_H_

/**
 * @brief Initializes the SysTick timer for 1ms periodic interrupts.
 * Configures SysTick to fire every 1ms using the processor clock.
 * Enables the SysTick interrupt which increments the millisecond
 * counter and calls sampleButton() on each tick.
 */
void systick_init(void);

/**
 * @brief SysTick interrupt handler, fires every 1ms.
 * Increments the global millisecond tick counter and calls
 * sampleButton() to update button debounce history.
 */
void SysTick_Handler(void);

/**
 * @brief Returns the number of milliseconds elapsed since program start.
 * @return unsigned int Milliseconds elapsed since systick_init() was called.
 */
unsigned int millis(void);

/**
 * @brief Blocks execution for the specified number of milliseconds.
 * Uses the SysTick millisecond counter to measure elapsed time.
 * @param the_delay Number of milliseconds to delay.
 */
void delay_ms(unsigned int the_delay);

#endif /* DELAY_H_ */
