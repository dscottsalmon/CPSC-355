//File: assign1b.asm
//Authors: Scott Salmon UCID - 30093320
//Date: September 27th, 2022

//Description: Assignment #1, Part 2
//A program in Assembly language (using macros) that finds the maximum of y = -4x^4 + 301x^2 + 56x - 103 in the range of -10=<x=<10

	define(xcurrent, x19)
	define(ycurrent, x20)
	define(xworking, x21)
	define(ap, x22)
	define(bp, x23)
	define(cp, x24)
	define(ymax,x25)
	define(storage,x27)
	define(stringaddr, x0)
	define(xint,x1)
	define(yint,x2)
	define(ymaxint,x3)
	
fmt:	
	.string "y = f(%d) = %d, Current Maximum 'y' value is: %d\n"	//string format

	.balign 4				
	.global main			
main:
	stp	x29, x30, [sp, -16]!			//Save FP and LR to the Stack
	mov	x29, sp					//Set FP to the stack addr

							//y(x) = ax^4 + bx^2 + cx + d
	mov	xcurrent, #-11				//initial value of x, starts at -11 because every loop x is incremented
	mov	ycurrent, #0				//inital y value
	mov	xworking, #0				//working value of x
	mov	ap, #-4					//a in polynomial
	mov	bp, #301				//b in polynomial
	mov	cp, #56					//c in polynomial
	mov	ymax, #-40000				//initial ymax, set low to not interfere with lt comparator in loop

top:
	mov 	ycurrent, #0				//resets y every time the loop runs
	add 	xcurrent, xcurrent, #1			//increments x by 1 every time the loop runs
	mov	xworking, xcurrent			//setting working x to current x

	add	ycurrent, ycurrent, -103		//y + d (constant)

	madd 	ycurrent, xcurrent, cp, ycurrent	//x * c + y
	
	mul	xworking, xcurrent, xcurrent		//x^2
	madd	ycurrent, xworking, bp, ycurrent	//x^2 * b + y

	mul 	xworking, xcurrent, xworking		//x*x^2  = x^3
	mul	xworking, xcurrent, xworking		//x*x^3  = x^4
	madd	ycurrent, xworking, ap, ycurrent	//x^4 * a + y

	cmp	ycurrent, ymax				//compares current max 'y' value and new 'y' value
	b.lt	next					//if true, skip to next. if false, then y > old maximum
	mov	ymax, ycurrent				//sets new max to whatever y is
	
next:	
	adrp 	stringaddr, fmt				//address of string
	add	stringaddr, stringaddr, :lo12:fmt	//address of string
	mov	xint, xcurrent				//setting x int
	mov	yint, ycurrent				//setting y int
	mov	ymaxint, ymax				//setting Max int
	bl	printf					//calls printf function
	
	cmp 	xcurrent, 9				//checks value of x
	b.gt	exit					//if x > 9, exit. if not, then reset the loop

	b 	top					//resets loop

exit:	
	ldp	x29, x30, [sp],16	//Restore the stack
	ret				//return to OS
