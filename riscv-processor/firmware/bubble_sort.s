.global _start
_start:

# create intentiaonal values that will be stored into memory 
addi x10, x0, 2
addi x11, x0, 10
addi x12, x0, 10
addi x13, x0, 55
addi x14, x0, 33

# memory address 
li x15, 0x00010000

# store values into memory sequentially 
sw x10, 0(x15)
sw x11, 4(x15)
sw x12, 8(x15)
sw x13, 12(x15)
sw x14, 16(x15)

# BUBBLE SORT VARIABLES
# x16 will be the variable that we add to x15 to increment the mem addr.
addi x16, x0, 4
# x17 will be the first register that we load data into
# x18 will be the second register that we load data into
# x21 will be the counter for how many swaps happen within an iteration
# this will let us know when we can finish the algorithm if no swaps happen within an iteration
addi x21, x0, 0
# x22 will hold the max mem addr 
li x22, 0x0001000c

# start sorting algorithm	
bubble_sort:
	# x15 = index
	lw x17, 0(x15)
	# x19 = index + 1
	add x19, x15, x16
	lw x18, 0(x19)
	
	# check equality
	beq x17, x18, check_end
	
	# check if x17 < x18 (rd = 1), or if x18 < x17 (rd = 0), place result in x20
	slt x20, x17, x18
	
	# if x20 = 0, we swap the data 
	beq x20, x0, swap_location
	
	# check if we are at the end of the array
	j check_end

	
swap_location:
	# increment swap counter
	addi x21, x21, 1
	
	# swap data in mem
	sw x18, 0(x15)
	sw x17, 0(x19)
	
check_end:
	beq x15, x22, reset
		
iterate:
	# increment array addr
	add x15, x15, x16
	j bubble_sort
			
reset: 
	# reset the x15 addr to the beginning of the list for the second iteration
	li x15, 0x00010000
	# if we had no swaps during that iteration, we are done 
	beq x21, x0, end
	# reset swap counter for next iteration
	addi x21, x0, 0
	j bubble_sort
		
end: 
	# load final mem values into registers to see if they're sorted
	lw x25, 0(x15)
	lw x26, 4(x15)
	lw x27, 8(x15)
	lw x28, 12(x15)
	lw x29, 16(x15)
	
	halt:
		jal x0, halt	