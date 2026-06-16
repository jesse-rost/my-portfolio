/**
 * @file        : joystick.h
 * @brief       : API header for analog joystick interface via ADC
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 8 - Analog Input
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 03/09/26
 */

#ifndef JOYSTICK_H_
#define JOYSTICK_H_

#include <stdint.h>

// calibration offset for X, physical center
#define JOY_X_OFFSET  0

// calibration offset for Y, physical center
#define JOY_Y_OFFSET  0

// deadband zone calculated based on interaction with personal hardware
#define JOY_DEADBAND  15


/*
 * Structure to hold the X and Y position of the joystick.
 * Both fields are signed 16-bit integers centered around 0.
 */
typedef struct {
	int16_t x;
	int16_t y;
}joyPosition;

/*
 * @brief  Initializes the ADC peripheral and interrupts for joystick reading.
 *         Configures PA0 and PA1 as analog inputs, sets up continuous scan
 *         mode on ADC1, and starts conversions.
 * @param  None
 * @return None
 */
void joy_init();

/*
 * @brief  Retrieves the latest X axis position of the joystick.
 *         Applies centering, calibration offset, and deadband.
 * @param  None
 * @return Signed 16-bit integer representing X position, centered around 0.
 */
int16_t joy_getX();

/*
 * @brief  Retrieves the latest Y axis position of the joystick.
 *         Applies centering, calibration offset, and deadband.
 * @param  None
 * @return Signed 16-bit integer representing Y position, centered around 0.
 */
int16_t joy_getY();

/*
 * @brief  Retrieves both X and Y positions of the joystick as a struct.
 *         Internally calls joy_getX() and joy_getY().
 * @param  None
 * @return joyPosition struct containing signed 16-bit X and Y values.
 */
joyPosition joy_getXY();


#endif /* JOYSTICK_H_ */
