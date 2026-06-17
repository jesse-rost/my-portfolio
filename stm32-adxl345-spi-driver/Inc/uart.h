/**
 * @file        : uart.h
 * @brief       : C terminal code using usart
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 3 - Buttons and LEDS
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 02/10/26
 */

#ifndef UART_H_
#define UART_H_

//Modify if changing the processor clock or target baud rate
#define F_CPU 16000000UL
#define BAUD 57600


// Function prototypes
extern void initUsart2();
extern char usart2Getch();
extern void usart2Putch(char c);

// syscalls overrides
int _read(int file, char *ptr, int len);
int _write(int file, char *ptr, int len);


#endif /* UART_H_ */
