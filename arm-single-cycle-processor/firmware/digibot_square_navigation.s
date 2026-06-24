@ --- Initialization Section ---
    MOV     R4, #0                  @ Initialize forward loop counter (R4) to 0
	MOV		R7, #0					@ Initialize turn loop counter (R7) to 0
    MOV     R0, #0xE4               @ Load MOTOR control register address (0xE4) into R0
	//LDR R0, =0xff200000
    MOV     R5, #0xEC               @ Load SENSOR input register address (0xEC) into R5
	//LDR R5, =0xff200050

	MOV		R8, #0xF0				@ Value for the SLIDERS
	//LDR 	R8, =0xff200040
	MOV		R9, #0xE0				@ Value for the LEDS
@ --- Start Going Straight ---
	MOV		R1, #0x0F
	STR     R1, [R0]
	B		count
	
count:
	@ --- Being Count loop ---
	LDR     R2, [R5] 				@ Reads sensors 
	AND     R2, R2, #0x04           @ Mask to check ONLY collision bit (bit 2)
    CMP     R2, #0                  @ Check if collision detected
	ADD 	R4, #1					@ Start Counting
    BNE     measure_drive_time      @ If there is a collision, branch
	B		count					@ If there is NOT a collision, continue counting 
	
measure_drive_time:
	MOV 	R1, #0x00
	STR     R1, [R0]				@ Stop the digibot
	MOV     R6, #0xE8               @ Load 7-segment display address (0xE8) into R0
    STR     R4, [R6]                @ Display current counter value on 7-segment display  

@ --- Start Going Left ---
	MOV 	R1, #0x03
	STR     R1, [R0]
	B		1f
	
@ --- Wait until collision sensor is OFF ---
1:
    LDR     R2, [R5]                @ Read sensors     
    AND     R2, R2, #0x04           @ Mask to check ONLY collision bit (bit 2)
    CMP     R2, #0x04               @ Check if collision is still detected
    BEQ     1b                      @ Continue looping until collision no longer detected
    B       count2                  @ Now start counting the turn time

count2:
	@ --- Being Count loop ---
	LDR     R2, [R5] 				@ Reads sensors 
	AND     R2, R2, #0x04           @ Mask to check ONLY collision bit (bit 2)
    CMP     R2, #0                  @ Check if collision detected
	ADD 	R7, #1					@ Start Counting
    BNE     measure_turn_time       @ If there is a collision, branch
	B		count2					@ If there is NOT a collision, continue counting 
	
measure_turn_time:
	MOV 	R1, #0x00
	STR     R1, [R0]				@ Stop the digibot
	MOV     R6, #0xE8               @ Load 7-segment display address (0xE8) into R0
    STR     R7, [R6]                @ Display current counter value on 7-segment display 
	B		draw_square	
	
draw_square:
	
	check_sliders:
		LDR     R3, [R8] 				@ Reads sliders 
		MOV		R10, #255
		ADD		R10, R10, #768
		CMP		R3, R10
		BNE		check_sliders
		
	@ Start going straght for the first side
	MOV		R1, #0x0F
	STR     R1, [R0]
	@ Save the values needed for the sides and turns

		MOV		R2, R4
	1: 	@ check if gone far enough for FIRST side
		CMP		R2, #0
		BEQ		2f
		SUB		R2, #1
		B		1b
		
	2: 	@ turn left 
		MOV		R3, R7
		2:
			MOV		R1, #0x03
			STR     R1, [R0]
			CMP		R3, #0
			BEQ		1f
			SUB		R3, #1
			B		2b
		
	1: 	@ check if gone far enough for SECOND side
		MOV		R2, R4
		1:
			MOV		R1, #0x0F
			STR     R1, [R0]
			CMP		R2, #0
			BEQ		2f
			SUB		R2, #1
			B		1b
		
		
	2: 	@ turn left 
		MOV		R3, R7
		2:
			MOV		R1, #0x03
			STR     R1, [R0]
			CMP		R3, #0
			BEQ		1f
			SUB		R3, #1
			B		2b
	
		
	1: 	@ check if gone far enough for THIRD side
		MOV		R2, R4	
		1:
			MOV		R1, #0x0F
			STR     R1, [R0]
			CMP		R2, #0
			BEQ		2f
			SUB		R2, #1
			B		1b
		
		
	2: 	@ turn left 
		MOV		R3, R7
		2:
			MOV		R1, #0x03
			STR     R1, [R0]
			CMP		R3, #0
			BEQ		1f
			SUB		R3, #1
			B		2b
		
		
	1: 	@ check if gone far enough for FOURTH(FINAL) side
		MOV		R2, R4
		1:
			MOV		R1, #0x0F
			STR     R1, [R0]
			CMP		R2, #0
			BEQ		2f
			SUB		R2, #1
			B		1b
	
stop_operation:
	MOV 	R1, #0x00
	STR     R1, [R0]				@ Stop the digibot
	MOV		R10, #255
	ADD		R10, R10, #768
	STR		R10, [R9]				@ Turn on LEDS
	MOV 	R1, #0x10				@ BEEP
	STR     R1, [R0]
	
	
@ --- delay ---
	
	MOV     R13, #0x3F    @ Outer loop counter (adjust for timing)
    
1:
    MOV     R11, #0xFF    @ Middle loop counter (255)
    
2:
    MOV     R12, #0xFF    @ Inner loop counter (255)
    
3:
    SUBS    R12, R12, #1  @ Decrement inner loop & set flags
    BNE     3b @ Repeat until R12 == 0
    
    SUBS    R11, R11, #1  @ Decrement middle loop
    BNE     2b
    
    SUBS    R13, R13, #1  @ Decrement outer loop
    BNE     1b
	
@ --- delay ---
		
	MOV		R10, #0
	STR		R10, [R9]				@ Turn off LEDS
	MOV 	R1, #0x10				@ BEEP
	STR     R1, [R0]
	
@ --- delay ---
	
	MOV     R10, #0x3F    @ Outer loop counter (adjust for timing)
    
1:
    MOV     R11, #0xFF    @ Middle loop counter (255)
    
2:
    MOV     R12, #0xFF    @ Inner loop counter (255)
    
3:
    SUBS    R12, R12, #1  @ Decrement inner loop & set flags
    BNE     3b @ Repeat until R12 == 0
    
    SUBS    R11, R11, #1  @ Decrement middle loop
    BNE     2b
    
    SUBS    R10, R10, #1  @ Decrement outer loop
    BNE     1b
	
@ --- delay ---
	
	MOV		R10, #255
	ADD		R10, R10, #768			@ Turn on LEDS
	MOV 	R1, #0x10				@ BEEP
	STR     R1, [R0]
		

@ --- delay ---
	
	MOV     R10, #0x3F    @ Outer loop counter (adjust for timing)
    
1:
    MOV     R11, #0xFF    @ Middle loop counter (255)
    
2:
    MOV     R12, #0xFF    @ Inner loop counter (255)
    
3:
    SUBS    R12, R12, #1  @ Decrement inner loop & set flags
    BNE     3b @ Repeat until R12 == 0
    
    SUBS    R11, R11, #1  @ Decrement middle loop
    BNE     2b
    
    SUBS    R10, R10, #1  @ Decrement outer loop
    BNE     1b
	
@ --- delay ---

	MOV		R10, #0
	STR		R10, [R9]				@ Turn off LEDS
	MOV 	R1, #0x10				@ BEEP
	STR     R1, [R0]
	
@ --- delay ---
	
	MOV     R10, #0x3F    @ Outer loop counter (adjust for timing)
    
1:
    MOV     R11, #0xFF    @ Middle loop counter (255)
    
2:
    MOV     R12, #0xFF    @ Inner loop counter (255)
    
3:
    SUBS    R12, R12, #1  @ Decrement inner loop & set flags
    BNE     3b @ Repeat until R12 == 0
    
    SUBS    R11, R11, #1  @ Decrement middle loop
    BNE     2b
    
    SUBS    R10, R10, #1  @ Decrement outer loop
    BNE     1b

@ --- delay ---

	MOV		R10, #255
	ADD		R10, R10, #768			@ Turn on LEDS
	MOV 	R1, #0x10				@ BEEP
	STR     R1, [R0]
	
end:
	bal end