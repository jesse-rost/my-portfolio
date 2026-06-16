/**
 * @file        : display_task.h
 * @brief       : includes the function prototype for the state machine
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 */

#ifndef DISPLAY_TASK_H_
#define DISPLAY_TASK_H_


typedef enum {
    DISPLAY_IDLE,
    DISPLAY_SCROLLING,
    DISPLAY_RETURNING
} display_state;

/**
 * @brief  Main display task handler.
 *
 *         Implements a finite state machine to control what is shown on
 *         the LED matrix. The task transitions between idle (bar graph),
 *         scrolling (single metric display), and returning states based
 *         on joystick input and timing.
 */
void display_task(void);

#endif /* DISPLAY_TASK_H_ */
