//File: a5a.asm
//Author(s): Scott Salmon UCID - 30093320

//Description: This source file, in combination with a5aMain.c makes a program that creates a "First in First Out"
//(FIFO) data structure. 

	.data
	.global head 			//Setting "head" as a global variable
	.global tail 			//Setting "tail" as a global variable
head:	.word   -1   			//Initializing head as -1 because the queue is empty
tail:	.word   -1  		 	//Initializing tail as -1 because the queue is empty

	.bss          			//Initializing the values of the queue to 0
	.global queue 			//Setting "queue" as a global variable
queue:	.skip   8 * 4 			//Initializes an integer array of 8 elements
	
	.text
qOverflow:	.string "\nQueue overflow! Cannot enqueue into a full queue.\n"
qUnderflow:	.string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
eQueue:		.string "\nEmpty queue\n"
cQueue:		.string "\nCurrent queue contents:\n"
qElement:	.string "  %d"
hQueue:		.string " <-- head of queue"
tQueue:		.string " <-- tail of queue"
newLine:	.string "\n"
	
	define(QUEUESIZE, 8)
	define(MODMASK, 0x7)
	define(FALSE, 0)
	define(TRUE, 1)

	.balign 4			//Aligning by 4 bytes
	.global queueEmpty		//Setting "queueEmpty" as a global subroutine
queueEmpty:
	stp	x29, x30, [sp, -16]!	//allocating memory
	mov	x29, sp			//setting fp to sp
	
	adrp	x0, head		//Calculate the address of the head
	add	x0, x0, :lo12:head	
	ldr	w1, [x0]		//Loads the value stored in head
	cmp	w1, -1			//Compares the value from head with -1 (-1 means the queue is empty)
	b.eq	qETrue			//If it is empty, return 1 (TRUE)
	mov	w0, FALSE		//Otherwise return 0 (FALSE)

	ldp	x29, x30, [sp], 16	//deallocating memoery
	ret

qETrue:	
	mov	w0, TRUE		//returning 1(TRUE) because queue was empty
	ldp	x29, x30, [sp], 16	//deallocating memory
	ret				//return to caller

	.balign 4			//aligning by 4 bytes
	.global queueFull		//setting"queueFull" as a global variable

queueFull:
	stp	x29, x30, [sp, -16]!	//allocating memory
	mov	x29, sp			//setting fp to sp
	
	adrp	x0, tail		//Calculates the address of tail
	add	x0, x0, :lo12:tail
	ldr	w1, [x0]		//Loads the value stored in tail into x1
	add	w1, w1, 1		//Increments tail value by 1
	and	w1, w1, MODMASK		//tail = ++tail & MODMASK
	adrp	x2, head		//Calculates the address of head
	add	x2, x2, :lo12:head
	ldr	w3, [x2]		//Loads the value stored in the head to x3

	cmp	w1, w3			//Compares the new value of tail with head
	b.eq	qFTrue			//If they're equal, return 1 (TRUE)
	mov	w0, FALSE		//Otherwise, return 0 (FALSE)
	ldp	x29, x30, [sp], 16	//deallocating memory
	ret				//return to caller

qFTrue:	
	mov	w0, TRUE		//Returning 1 (TRUE)
	ldp	x29, x30, [sp], 16	//deallocating memory
	ret				//return to caller

	.balign 4			//aligned by 4 bytes
	.global dequeue			//setting "dequeue" as a global subroutine

dequeue:
	stp	x29, x30, [sp, -16]!	//allocating memory
	mov	x29, sp			//setting fp to sp
	
	bl	queueEmpty		//Checks to see if the queue is currently empty
	cmp	w0, 1			//Compares if queue is empty (1) or if it's not empty (0)
	b.eq	qUnderflowMessage	//If it's empty, print an error saying you can't dequeue an empty queue

	adrp	x0, head		//Calculates address of head
	add	x0, x0, :lo12:head
	ldr	w3, [x0]		//Loads the value stored in head, store in w3
	adrp	x1, queue		//Calculate the address of queue
	add	x1, x1, :lo12:queue
	ldr	w7, [x1, w3, SXTW 2]	//temp var value = queue[head]
	adrp	x2, tail		//Calculate the address of tail
	add	x2, x2, :lo12:tail
	ldr	w4, [x2]		//Load the value stored in tail, store in w4
	cmp	w3, w4			//Check to see if tail and head are equal
	b.eq	dQTrue			//If they are, branch
	add	w3, w3, 1		//increment head by 1
	and	w3, w3, MODMASK		//head = ++head & MODMASK
	str	w3, [x0]		//Store the new head value
	b	contdq			//branch to contdq

dQTrue:					//used if queue only has one element
	mov	w3, -1			//moving -1 into w3
	str	w3, [x0]		//setting head to -1
	str	w3, [x2]		//setting tail to -1

contdq:	
	mov	w0, w7			//Return value after operations are done
	ldp	x29, x30, [sp], 16	//deallocating memory
	ret				//returns to caller

qUnderflowMessage:
	adrp	x0, qUnderflow		//loading qUnderflow string
	add	x0, x0, :lo12:qUnderflow
	bl	printf			//calls printf function
	mov	w0, -1			//Returns -1 to the main routine
	ldp	x29, x30, [sp], 16	//deallocating memory
	ret				//return to caller

	.balign 4			//aligned by 4 bytes
	.global enqueue			//sets "enqueue" as a global subroutine

enqueue:
	stp	x29, x30, [sp, -(16 + 8) & -16]! //allocates memoery
	mov	x29, sp			//sets fp to sp

	str	x19, [x29, 16]		//Saves x19's state
	
	mov	w19, w0			//Protects the passed argument from being overwritten
	
	bl	queueFull		//Checks if the queue is full, returns value to w0
	cmp	w0, 1			//compares w0 and 1 (TRUE) 
	b.eq	qFullError		//if w0 is full (=1), print error

	bl	queueEmpty		//Checks if the queue is empty, returns value to w0
	cmp	w0, 1			//compares w0 and 1 (TRUE)
	b.ne	eQFalse			//if w0 is empty (!=1), print error
	
	adrp	x0, head		//Calculate the address of head
	add	x0, x0, :lo12:head 
	mov	w7, 0			//temp variable = 0
	str	w7, [x0]		//Store 0 in the head variable
	adrp	x1, tail		//Calculate the address of tail
	add	x1, x1, :lo12:tail 
	str	w7, [x1]		//Store 0 in the tail variable
	b	contq			//branch to contq

eQFalse: 				//used when the queue is NOT empty
	adrp	x1, tail		//Calculate the address of the tail
	add	x1, x1, :lo12:tail
	ldr	w2, [x1]		//Load the value stored in tail to w2
	add	w2, w2, 1		//Increment it by 1
	and	w2, w2, MODMASK		//Apply a bitmask of 0x7 to it
	str	w2, [x1]		//Store that value back as the new tail value
	
contq:	
	adrp	x0, queue		//Calculate the address of the queue array
	add	x0, x0, :lo12:queue
	ldr	w2, [x1]		//Load the value stored in tail
	str	w19, [x0, w2, SXTW 2]	//Store the value passed to this subroutine at queue[tail]

	ldr	x19, [x29, 16]		// Restore x19 state

	ldp	x29, x30, [sp], -(-(16 + 8) & -16)	//deallocate memory
	ret				//return to caller

qFullError:				//prints error if queue is full
	adrp	x0, qOverflow		//loads qOverflow string
	add	x0, x0, :lo12:qOverflow
	bl	printf			//calls printf

	ldr	x19, [x29, 16]		// Restore x19 state
	ldp	x29, x30, [sp], -(-(16 + 8) & -16)	//deallocates memory
	ret				//return to caller


	.balign 4			//aligned by 4 bytes
	.global display			//sets "display" to a global subroutine
display:				//Displays the elements of the queue
	stp	x29, x30, [sp, -(16 + 48) & -16]!	//allocates memory
	mov	x29, sp			//sets fp to sp

	str	x19, [x29, 16]		//Saving the states of registers
	str	x20, [x29, 24]
	str	x21, [x29, 32]
	str	x22, [x29, 40]
	str	x23, [x29, 48]
	str	x24, [x29, 56]
	
	bl	queueEmpty		//Checks if the queue is empty, returns boolean to w0
	cmp	w0, 1			//Compares w0 and 1 (TRUE)
	b.eq	dEQ			//If it is full (=1), print and return to calling code

	adrp	x0, tail		//Calculates the address of tail variable
	add	x0, x0, :lo12:tail 
	adrp	x1, head		// Calculates the address of head variable
	add	x1, x1, :lo12:head
	ldr	w19, [x0]		//loads value of tail into w19
	ldr	w20, [x1]		//loads value of head into w20
	mov	w21, w19		//count = tail
	sub	w21, w21, w20		//count = tail - head
	add	w21, w21, 1		//count = tail - head + 1

	cmp	w21, 0			//Compare count and 0 if count > 0
	b.gt	dCont1			//If count>0, don't add the QUEUESIZE to it
	add	w21, w21, QUEUESIZE
	
dCont1:	
	adrp	x0, cQueue		//Loads current queue contents string
	add	x0, x0, :lo12:cQueue
	bl	printf			//calls printf function

	mov	w22, w20		//i = head
	mov	w23, 0			//j = 0

	b	test			//branches to test

dloop:	
	adrp	x0, queue		//Calculates the address of the queue
	add	x0, x0, :lo12:queue
	ldr	w24, [x0, w22, SXTW 2] 	//Loads queue[i]

	adrp	x0, qElement		//Prints out queue[i]
	add	x0, x0, :lo12:qElement
	mov	w1, w24
	bl	printf			//calls printf function

	cmp	w22, w20		//Compares i and head
	b.ne	dCont2			//If i != head, branch to dCont2
	adrp	x0, hQueue		//loading head of queue string
	add	x0, x0, :lo12:hQueue
	bl	printf			//calls printf function

dCont2:	cmp	w22, w19		//Checks whether i == tail
	b.ne	dCont3			//If i != tail, branch to dCont3
	adrp	x0, tQueue		//loading tail of queue string
	add	x0, x0, :lo12:tQueue
	bl	printf			//calls printf function

dCont3:	adrp	x0, newLine		//loading "\n" string
	add	x0, x0, :lo12:newLine
	bl	printf			//call printf function

	add	w22, w22, 1		//increment i by 1
	and	w22, w22, MODMASK	//i = ++i & MODMASK
	add	w23, w23, 1		//increment j by 1

test:	cmp	w23, w21		//Loop if j < count
	b.lt	dloop

	ldr	x19, [x29, 16]		//restoring register states
	ldr	x20, [x29, 24]
	ldr	x21, [x29, 32]
	ldr	x22, [x29, 40]
	ldr	x23, [x29, 48]
	ldr	x24, [x29, 56]
	
	ldp	x29, x30, [sp], -(-(16 + 48) & -16)	//deallocating memory
	ret				//Return to caller
	
dEQ:	adrp	x0, eQueue		//load empty queue string
	add	x0, x0, :lo12:eQueue 
	bl 	printf			//call printf function
	ldp	x29, x30, [sp], -(-(16 + 48) & -16)	//deallocating memory
	ret				//return to caller


