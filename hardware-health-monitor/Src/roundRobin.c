/*
 * roundRobin.c
 *
 *  Created on: May 2, 2026
 *      Author: rostj
 */
#include <stdint.h>
#include <stdlib.h>          // for calloc and malloc
#include "roundRobin.h"

// pointer to SCB ICSR register for triggering PendSV
static volatile uint32_t *scb_icsr = (uint32_t*)SCB_ICSR;

// global state variables
static uint32_t num_tasks = 0;
static uint32_t current_task = 0;
static uint32_t next_task = 0;
static task *tasks = NULL;

void init_tasker(uint32_t total_tasks, uint32_t main_ticks) {
	num_tasks = total_tasks;
// using calloc to init to 0
	tasks = calloc(total_tasks, sizeof(task));
// task 0 will be the "main" task
	tasks[0].state = ACTIVE;
	tasks[0].ticks_starting = main_ticks;
	tasks[0].ticks_remaining = main_ticks;
// no need to set stack pointer for task 0 as it will
// be running at time of first swap
	current_task = 0;
}

// init_task
void init_task(uint32_t task_num, uint32_t stacksize, void (*entry_point)(void),
		uint32_t ticks) {
	tasks[task_num].stack_pointer = (uint32_t*) malloc(
			stacksize * sizeof(uint32_t));
// need to point to top of block, not bottom
	tasks[task_num].stack_pointer += stacksize;
// fill stack with appropriate frame
	*(--tasks[task_num].stack_pointer) = 0x01000000; // PSR - must have Thumb state bit set
	*(--tasks[task_num].stack_pointer) = ((uint32_t) entry_point); // PC
	*(--tasks[task_num].stack_pointer) = 0xFFFFFFFF; // LR
	*(--tasks[task_num].stack_pointer) = 0; // R12
	*(--tasks[task_num].stack_pointer) = 0; // R3
	*(--tasks[task_num].stack_pointer) = 0; // R2
	*(--tasks[task_num].stack_pointer) = 0; // R1
	*(--tasks[task_num].stack_pointer) = 0; // R0
	*(--tasks[task_num].stack_pointer) = 0xFFFFFFF9; // ISR LR
	*(--tasks[task_num].stack_pointer) = 0; // R11
	*(--tasks[task_num].stack_pointer) = 0; // R10
	*(--tasks[task_num].stack_pointer) = 0; // R9
	*(--tasks[task_num].stack_pointer) = 0; // R8
	*(--tasks[task_num].stack_pointer) = 0; // R7
	*(--tasks[task_num].stack_pointer) = 0; // R6
	*(--tasks[task_num].stack_pointer) = 0; // R5
	*(--tasks[task_num].stack_pointer) = 0; // R4
	tasks[task_num].state = ACTIVE;
	tasks[task_num].ticks_starting = ticks;
	tasks[task_num].ticks_remaining = 0;
}

// called by SysTick timer ISR every 1 ms
void tasker_tick() {
// decrement tick
	tasks[current_task].ticks_remaining--;
// hit zero?
	if (tasks[current_task].ticks_remaining == 0) {
// find next active task
		uint32_t i = 1;
		while (tasks[(next_task = (current_task + i) % num_tasks)].state
				!= ACTIVE) {
			i++;
		}
// have a new task in next_task
		tasks[next_task].ticks_remaining = tasks[next_task].ticks_starting;
// trigger swap
		*scb_icsr |= 1 << PENDSVSET;
	}
}

void PendSV_Handler(void) {
	register uint32_t *stack_pointer asm("r13");
	asm volatile("push {r4-r11,lr}");
	tasks[current_task].stack_pointer = stack_pointer;
	current_task = next_task;
	stack_pointer = tasks[current_task].stack_pointer;
	asm volatile("pop {r4-r11,lr}\n\t"
			"bx lr");
}
