/**
 * @file        : delay.c
 * @brief       : calculated a delay based on my personal hardware
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 3 - Buttons and LEDS
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 03/02/26
 */

#include <stdint.h>
#include "delay.h"
#include "regaddr.h"
#include "button.h"


/**
 * @brief Initializes the SysTick timer for 1ms periodic interrupts.
 * Configures SysTick to fire every 1ms using the processor clock.
 * Enables the SysTick interrupt which increments the millisecond
 * counter and calls sampleButton() on each tick.
 */
void systick_init(void){

	//pointer to peripheral
	SYSTICK* systick = (SYSTICK*)SYSTICK_BASE;

	// just incase timer was used previously
	systick->CTRL = 0;

	// load delay 1ms * clock_speed (ticks/second) - 1
	systick->LOAD = TICKS_PER_MS - 1;

	// clear old count value (per programming manual)
	systick->VAL = 0;

	// start counter at processor speed (no need for RMW here)
	systick->CTRL = CLKSOURCE | ENABLE | TICKINT;

	// done
}

static volatile unsigned int ticks = 0;

/**
 * @brief SysTick interrupt handler, fires every 1ms.
 * Increments the global millisecond tick counter and calls
 * sampleButton() to update button debounce history.
 */
void SysTick_Handler(void){

	ticks++;
	sampleButton();
}

/**
 * @brief Returns the number of milliseconds elapsed since program start.
 * @return unsigned int Milliseconds elapsed since systick_init() was called.
 */
unsigned int millis(void){

	return ticks;

}

/**
 * @brief Blocks execution for the specified number of milliseconds.
 * Uses the SysTick millisecond counter to measure elapsed time.
 * @param the_delay Number of milliseconds to delay.
 */
void delay_ms(unsigned int the_delay){

	unsigned int start = ticks;

	while((ticks-start) < the_delay) {
		// do nothing
	}
	// done
}

