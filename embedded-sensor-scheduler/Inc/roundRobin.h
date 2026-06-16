/**
 * @file        : bme280.h
 * @brief       : includes the function prototype for the temp sensor
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Final Lab
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 05/05/26
 *
 * @note        Implementation was developed with reference to
 *              Dr. Rothe’s course lecture slides.
 */

#ifndef ROUNDROBIN_H_
#define ROUNDROBIN_H_

#define SCB_ICSR 0xE000ED04
#define PENDSVSET 28

typedef enum {
	PAUSED, ACTIVE
} task_state;

typedef struct {
	uint32_t *stack_pointer;
	task_state state;
	uint32_t ticks_starting;
	uint32_t ticks_remaining;
} task;

/**
 * @brief  Scheduler tick handler.
 *
 *         Called periodically (e.g., from a SysTick interrupt) to update
 *         task timing. Decrements the currently running task's remaining
 *         ticks and triggers a context switch when the time slice expires.
 */
void tasker_tick();

/**
 * @brief  Initializes the round-robin scheduler.
 *
 *         Sets up internal scheduler structures, including the total
 *         number of tasks and the default time slice for the main task.
 *
 * @param  total_tasks  Total number of tasks to be managed.
 * @param  main_ticks   Time slice (in ticks) allocated to the main task.
 */
void init_tasker(uint32_t total_tasks, uint32_t main_ticks);

/**
 * @brief  Initializes a task and adds it to the scheduler.
 *
 *         Allocates and sets up the task's stack, assigns its entry point,
 *         and configures its time slice. The task is prepared for execution
 *         during scheduling.
 *
 * @param  task_num     Index of the task in the scheduler.
 * @param  stacksize    Size of the task stack (in bytes or words, depending on implementation).
 * @param  entry_point  Function pointer to the task's starting function.
 * @param  ticks        Time slice (in ticks) allocated to this task.
 */
void init_task(uint32_t task_num, uint32_t stacksize, void (*entry_point)(void),
		uint32_t ticks);

/**
 * @brief  PendSV exception handler for context switching.
 *
 *         Performs the low-level context switch between tasks by saving
 *         the current task state and restoring the next task's state.
 */
void PendSV_Handler(void) __attribute__((naked));

#endif /* ROUNDROBIN_H_ */
