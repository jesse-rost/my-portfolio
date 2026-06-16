/**
 * @file        : display_task.h
 * @brief       : includes the function definitions for the state machine
 * 				  along with the state functions of which are private to this
 * 				  file.
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 */

#include "display_task.h"
#include "matrix.h"
#include "joystick.h"
#include "ina219.h"
#include "bme280.h"
#include "delay.h"
#include "stdio.h"

static int8_t metric_index = 0;

static display_state state_idle(void);
static display_state state_scrolling(void);
static display_state state_returning(void);

void display_task(void){
	static display_state state = DISPLAY_IDLE;
	switch (state) {
	case DISPLAY_IDLE:
		state = state_idle();
		break;
	case DISPLAY_SCROLLING:
		state = state_scrolling();
		break;
	case DISPLAY_RETURNING:
		state = state_returning();
		break;
	}
}

/**
 * @brief  Handles the DISPLAY_IDLE state.
 *
 *         Displays a bar graph of voltage, current, and temperature.
 *         Monitors joystick input to detect left/right movement and
 *         transitions to the scrolling state when input is detected.
 *
 * @return display_state  Next state of the state machine.
 */
static display_state state_idle() {
	 int16_t x = joy_getX();
	// display the bargraph
	matrix_bargraph(g_voltage, g_current, g_temp);


	if (x > 500) {
	        metric_index = (metric_index + 1) % 3;
	        delay_ms(300);  // debounce
	        return DISPLAY_SCROLLING;
	    } else if (x < -500) {
	        metric_index = (metric_index + 2) % 3;
	        delay_ms(300);  // debounce
	        return DISPLAY_SCROLLING;
	    }
	return DISPLAY_IDLE;

}

/**
 * @brief  Handles the DISPLAY_SCROLLING state.
 *
 *         Displays the selected metric (voltage, current, or temperature)
 *         as a formatted numeric value. Allows the user to cycle through
 *         metrics using the joystick.
 *
 *         If no input is detected for a fixed timeout period (~3 seconds),
 *         transitions to the returning state.
 *
 * @return display_state  Next state of the state machine.
 */
static display_state state_scrolling() {
    int16_t x = joy_getX();
    static uint8_t fresh_entry = 1;
    static uint32_t pause_start = 0;

    if (fresh_entry) {
        fresh_entry = 0;
        pause_start = millis();
    }

    // display the value statically
    matrix_display_value(metric_index, g_voltage, g_current, g_temp);

    // check joystick
    if (x > 500) {
        fresh_entry = 1;
        metric_index = (metric_index + 1) % 3;
        while(joy_getX() > 100);
        delay_ms(100);
        return DISPLAY_SCROLLING;
    } else if (x < -500) {
        fresh_entry = 1;
        metric_index = (metric_index + 2) % 3;
        while(joy_getX() < -100);
        delay_ms(100);
        return DISPLAY_SCROLLING;
    }

    // after 3 seconds return to returning state
    if ((millis() - pause_start) >= 3000) {
        fresh_entry = 1;
        return DISPLAY_RETURNING;
    }
    return DISPLAY_SCROLLING;
}

/**
 * @brief  Handles the DISPLAY_RETURNING state.
 *
 *         Acts as a delay period before returning to the idle state.
 *         Continues to monitor joystick input, allowing immediate
 *         transition back to the scrolling state if user interaction
 *         occurs.
 *
 *         After a timeout (~3 seconds), transitions back to idle.
 *
 * @return display_state  Next state of the state machine.
 */
static display_state state_returning() {
	 int16_t x = joy_getX();
	static uint8_t fresh_entry = 1;
	static uint32_t start_time = 0;

	if (fresh_entry) {
		fresh_entry = 0;
		start_time = millis();  // record when we entered
	}

	// check joystick
	if (x > 500) {
	        metric_index = (metric_index + 1) % 3;
	        delay_ms(300);  // debounce
	        return DISPLAY_SCROLLING;
	    } else if (x < -500) {
	        metric_index = (metric_index + 2) % 3;
	        delay_ms(300);  // debounce
	        return DISPLAY_SCROLLING;
	    }
	// check if 3 seconds have passed
	if ((millis() - start_time) >= 3000) {
		fresh_entry = 1;
		return DISPLAY_IDLE;
	}
	return DISPLAY_RETURNING;
}

