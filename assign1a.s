//File: assign1a.s
//Authors: Scott Salmon UCID - 30093320
//Date: September 22nd-27th, 2022

//Description: Assignment #1, Part 1
//A program in Assembly language that finds the maximum of y = -4x^4 + 301x^2 + 56x - 103 in the range of -10=<x=<10

//NOTE: In my script file, instead of using the p/d $x## at important points, I used display $x## at the beginning instead.
//This made more sense to me and showed what was in my registers for every step. I hope that's okay.
//The order I used on displays was: x, y, max, a, b, c, storage variable.

fmt:	
	.string "y = f(%d) = %d, Current Maximum 'y' value is: %d\n"	//string format

	.balign 4				
	.global main			
main:
	stp	x29, x30, [sp, -16]!	//Save FP and LR to the Stack
	mov	x29, sp			//Set FP to the stack addr

					//y(x) = ax^4 + bx^2 + cx + d
	mov	x19, #-11		//x19 = initial value of x, starts at -11 because 1 is added at the start of every loop
	mov	x20, #0			//x20 = initial value of y
	mov	x21, #0			//working value of x
	mov	x22, #-4		//a
	mov	x23, #301		//b
	mov	x24, #56		//c
	mov	x25, #-40000		//maximum y value, set really low to not interfere with lt comparator in loop
	mov	x27, #0			//storage variable for calculations

top:
	mov 	x20, #0			//resets y every time the loop runs
	add 	x19, x19, #1		//increments x by 1 every time the loop runs
	mov	x21, x19		//setting working x to current x

	cmp	x19, 10			//checkes to see if x=11, if so then the loop is killed
	b.gt	exit			//pre-loop

	add	x20, x20, -103		//y + d (constant)

	mul 	x27, x21, x24		//x * c, saving to storage variable
	add	x20, x20, x27		//y + (x*c) = y + storage

	mul	x21, x19, x19		//x^2
	mul	x27, x21, x23		//x^2 * b, storing in storage variable
	add	x20, x20, x27		//y + (x^2 * b) = y + storage

	mul 	x21, x19, x21		//x*x^2  = x^3
	mul	x21, x19, x21		//x*x^3  = x^4
	mul	x27, x21, x22		//x^4 * a, storing in storage variable
	add	x20, x20, x27		//y + (x^4 * a) = y + storage

	cmp	x20, x25		//compares current max 'y' value and new 'y' value
	b.lt	next			//if true, skip to next. if false, then y > old maximum
	mov	x25, x20		//sets new max to whatever y is
	
next:	
	adrp 	x0, fmt			//address of string
	add	x0, x0, :lo12:fmt	//address of string
	mov	x1, x19			//setting x int
	mov	x2, x20			//setting y int
	mov	x3, x25			//setting Max int
	bl	printf			//calls printf function

	b 	top			//resets loop


exit:	
	ldp	x29, x30, [sp],16	//Restore the stack
	ret				//return to OS
