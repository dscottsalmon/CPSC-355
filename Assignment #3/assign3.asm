//File: assign3.asm
//Authors: Scott Salmon UCID - 30093320
//Date: October 17th-19th

//Description: Assignment #3
//A program in Assembly language that creates an array of length 40 with random positive integers,
//and then sorts the array numerically. All local variables are to be stored on the stack, and 
//all assembler equates are to be stored as macros


	define(SIZE, 40)			//not a local variable in original c program, so saved as a macro
	define(memory, 188) 			//array_size + i_size + j_size + j-1_size
						//= (40*4) + 4 + 4 + 40 = 43*4 = 172
						//memory = 172  + 16 = 188

	define(i_s, 16)	      			//address for i
	define(array_s,20)			//base array address
	define(j_s, 180)			//address of j
	define(jo_s,184)			//address of j-1

fmt:
	.string "v[%d]: %d\n"			//string format for printing the array value at an index
fmt2:
	.string "\nSorted Array: \n"		//string format for Sorted Array

	.balign 4
	.global main

main:
	stp	fp, lr, [sp,-(memory) & -16]!	//Save FP and LR to the stack
	mov	fp, sp				//Set FP to the stack addr

	mov	w19, 0				//initialize i = 0
	str	w19, [fp, i_s]			//store i in stack

	b 	test
loop:
	bl	rand				//generates random number, result is in w0
	and	w20, w0, 0xFF			//mod the result with 256, store in w20
	ldr	w19, [fp, i_s]			//load i into w19
	add	x26, fp, array_s		//calculate array base address
	str	w20, [x26, w19, sxtw 2] 	//store the random number into the stack

	adrp	x0, fmt				//print
	add	x0, x0, :lo12:fmt		//print
	ldr	w1, [fp, i_s]			//load i, store in w1 for printing
	ldr	w2, [x26, w19, sxtw 2]		//load array value, store in w2 for printing
	bl	printf				//call printf

	add	w19, w19, 1			//increment i by 1
	str	w19, [fp, i_s]			//update i in stack

test: 	
	ldr	w19, [fp, i_s]			//load i from the stack
	cmp	w19, SIZE			//compares i and SIZE
	b.lt 	loop				//if i<SIZE, return to loop

next: 
	mov	w19, SIZE			//initialize i = SIZE
	str	w19, [fp, i_s]			//storing new i in stack

	b 	test2

loop2:
	ldr	w19, [fp, i_s]			//loading i from stack
	sub	w19, w19, 1			//subtracting 1 from i
	cmp	w19, 0
	b.lt	final				//if i<0, go to final
	str	w19, [fp, i_s]			//storing new i in stack
	
	mov	w20, 0				//initializing j 
	mov	w21, -1				//initializing j-1
	str	w20, [fp, j_s]			//storing j in stack
	str	w21, [fp, jo_s]			//storing j-1 in stack

innerloop:
	ldr	w19, [fp, i_s]			//loading i from stack
	add	x26, fp, array_s		//calculating stack address

	ldr	w20, [fp, j_s]			//loading j
	add	w20, w20, 1			//incrementing j by 1
	cmp	w20, w19
	b.gt	loop2				//if j>i, then go to loop2

	ldr	w22, [x26, w20, sxtw 2]		//loading v[j] from stack
	str	w20, [fp, j_s]			//storing j in stack
	ldr	w21, [fp, jo_s]			//loading j-1
	add	w21, w21, 1			//incrementing j-1 by 1
	ldr	w23, [x26, w21, sxtw 2]		//loading v[j-1]
	str	w21, [fp, jo_s]			//storing j-1 in stack

	cmp	w22, w23			//comparing v[j] and v[j-1]
	b.gt	innerloop			//if v[j]>v[j-1], go back to innerloop
	
	str	w22, [x26, w21, sxtw 2]		//storing v[j] in v[j-1]
	str	w23, [x26, w20, sxtw 2]		//storing v[j-1] in v[j]
	b 	innerloop

test2:	
	ldr	w19, [fp,i_s]			//load i from the stack
	cmp	w19, 0				//comparing i to 0
	b.ge	loop2				//if i>=0, go to loop2

final:
	adrp	x0, fmt2			//address of Sorted Address string
	add	x0, x0, :lo12:fmt2		//address of Sorted Address String
	bl	printf				//calls printf function

	mov	w19, 0				//initializes i = 0
	str	w19, [fp, i_s]			//stores i in stack
	b	test3

loop3:
	adrp	x0, fmt				//address of string
	add	x0, x0, :lo12:fmt		//address of string
	ldr	w1, [fp, i_s]			//loads i from stack, stores in w1 for printing
	ldr	w2, [x26, w1, sxtw 2]		//loads v[i] from stack, stores in w2 for printing
	bl 	printf				//calls printf

	add	w19, w19, 1			//increments i by 1
	str	w19, [fp, i_s]			//store i in stack
test3:
	ldr	w19, [fp, i_s]			//loads i from stack
	cmp	w19, SIZE			//compares i to SIZE
	b.lt	loop3				//if i<SIZE, return to loop

exit:
	ldp	fp, lr, [sp], -(-(memory) & -16)	//Restore the stack
	ret						//return to OS
