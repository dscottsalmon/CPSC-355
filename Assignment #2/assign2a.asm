//File: assign2a.asm
//Authors: Scott Salmon UCID - 30093320
//Date: October 2nd-3rd, 2022

//Description: Assignment #2, Part 1
//A program in Assembly language that peforms a bit reversal using Shift and Bitwise Logical Operations
//Based on the C program outlined on the Assignment #2 description sheet.

//in the gdb script, instead of printing hex/binary at the end, i used display to show the hex/binary values 
//every step throughout the program for the original and reversed value. 

//Initial Variable: x = 0x07fc07fc

	define(org, w19)	//variables
	define(rev, w20)
	define(t1,w21)
	define(t2,w22)
	define(t3,w23)
	define(t4,w24)
	define(stor,w25)

fmt:
	.string "Original: 0x%08x Reversed: 0x%08x\n"	//string format

	.balign 4
	.global main

main:
	stp	x29, x30, [sp, -16]!	//Save FP and LR to the stack
	mov	x29, sp			//Set FP to the stack addr
	
	mov	org, 0x07fc07fc		//initializing original value

	//Step 1	
	and	t1, org, 0x55555555	//finding bits in BOTH original and 0x55555555
	lsl	t1, t1, 1		//shifting a zero into the rightmost bit in t1
	lsr	stor, org, 1		//shifting a zero into the leftmost bit in org, then putting that into storage	
	and	t2, stor, 0x55555555	//finding bits in BOTH storage and 0x55555555	
	orr	rev, t1, t2		//finding bits in EITHER t1 and t2, storing in reverse
	
	//Step 2
	and	t1, rev, 0x33333333	//finding bits in BOTH reverse and 0x33333333
	lsl	t1, t1, 2		//shifting zeroes into the rightmost 2 bits in t1
	lsr	stor, rev, 2		//shifting zeroes into the leftmost 2 bits in rev, then putting into storage
	and	t2, stor, 0x33333333	//finding bits in BOTH storage and 0x33333333
	orr	rev, t1, t2		//finding bits in EITHER t1 and t2, storing in reverse

	//Step 3
	and	t1, rev, 0x0F0F0F0F	//finding bits in BOTH reverse and 0x0F0F0F0F
	lsl	t1, t1, 4		//shifting zeroes into the rightmost 4 bits in t1
	lsr	stor, rev, 4		//shifting zeroes into the leftmost 4 bits in rev, then putting into storage
	and	t2, stor, 0x0F0F0F0F	//finding bits in BOTH storage and 0x0F0F0F0F
	orr	rev, t1, t2		//finding bits in EITHER t1 and t2, storing in reverse

	//Step 4
	lsl	t1, rev, 24		//shifting zeroes into the rightmost 24 bits in t1
	and	t2, rev, 0xFF00		//finding bits in BOTH reverse and 0xFF00, storing in t2
	lsl	t2, t2, 8		//shifting zeroes into the rightmost 8 bits in t2
	lsr	stor, rev, 8		//shifting zeroes into the leftmost 8 bits in rev, then putting into storage
	and	t3, stor, 0xFF00	//finding bits in BOTH storage and 0xFF00, storing in t3
	lsr	t4, rev, 24		//shifting zeroes into leftmost 24 bits in reverse, then storing in t4
	orr 	rev, t1, t2		//finding bits in EITHER t1 and t2, storing in reverse
	orr	rev, rev, t3		//finding bits in EITHER reverse and t3, storing in reverse
	orr 	rev, rev, t4		//finding bits in EITHER reverse and t4, storing in reverse

next:
	adrp	x0, fmt			//address of string
	add	x0, x0, :lo12:fmt	//address of string
	mov	w1, org			//setting original value
	mov	w2, rev			//setting reverse value
	bl	printf			//calls printf function
exit:
	ldp	x29, x30, [sp],16	//Restore the stack
	ret				//return to OS
