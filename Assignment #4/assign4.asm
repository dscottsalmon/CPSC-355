//File: assign4.asm
//Authors: Scott Salmon UCID - 30093320
//Date: October 31st-November 1st

//Description: A program written in Assembly language that creates two cuboids located at the origin (0,0), with dimensions
//2x2x3. The program prints these values along with the calculated volumes of each cuboid. Then one cubiod is shifted 3 to
//the right, and 6 down, and the other cuboid is scaled up by a factor of 4. The new values for length, width, height and volume
//of the cubiods are then printed.

	define(False, 0)				//boolean true and false variables
	define(True, 1)					//global variables in original C program, so macros in this program

fmt:	.string "Cuboid %s Origin = (%d, %d)\n\tBase Width = %d\tBase length = %d\n\tHeight = %d\n\tVolume = %d\n\n\n"	//format of string of values

fmt2:	.string "Initial Cuboid Values: \n"		//format of initial cuboid print statement
fmt3:	.string "Changed Cuboid Values: \n"		//format of change cuboid print statement

first:	.string "First"					//string of First
second:	.string "Second"				//string of Second

	.balign 4					//aligned by 4 bytes
	.global main					

	xCoord_s = 0					//location x coordinate is stored
	yCoord_s = 4					//location y coordinate is stored
	width_s = 8					//location width value is stored
	length_s = 12					//location length value is stored
	height_s = 16					//location height value is stored
	volume_s = 20					//location volume value is stored
							//Note: Cuboid Size = 24

	alloc = -(16 + 8) & -16				//allocating memory
	dealloc = -alloc				//allocating memory

	cuboid_s = 16					//location new cuboids are stored
	first_s = 16					//location first cuboid is stored
	second_s = 40					//location second cuboid is stored
							//16 + 24 = 40

newCuboid:
	stp 	x29, x30, [sp,alloc]!			//allocating memory
	mov	x29, sp					//setting fp to sp

	mov 	w1, 0					//setting x coordinate
	str	w1, [x29, cuboid_s + xCoord_s]		//storing x coordinate
	
	mov	w2, 0					//setting y coordinate
	str	w2, [x29, cuboid_s + yCoord_s]		//storing y coordinate

	mov	w3, 2					//setting width value
	str	w3, [x29, cuboid_s + width_s]		//storing width value

	mov	w4, 2					//setting length value
	str	w4, [x29, cuboid_s + length_s]		//storing length value
	
	mov	w5, 3					//setting height value
	str	w5, [x29, cuboid_s + height_s]		//storing height value

	mul	w6, w3, w4				//width*length = base, stored in w6
	mul	w6, w5, w6				//base*height = volume, stored in w6
	str	w6, [x29, cuboid_s + volume_s]		//storing volume value

	ldr	w9, [x29, cuboid_s + xCoord_s]		//loading x coordinate
	str	w9, [x8, xCoord_s]			//returning x coordinate to caller

	ldr	w9, [x29, cuboid_s + yCoord_s]		//loading y coordinate
	str	w9, [x8, yCoord_s]			//returning y coordinate to caller

	ldr	w9, [x29, cuboid_s + width_s]		//loading width value
	str	w9, [x8, width_s]			//returning width value to caller

	ldr	w9, [x29, cuboid_s + length_s]		//loading length value
	str	w9, [x8, length_s]			//returning length value to caller

	ldr	w9, [x29, cuboid_s + height_s]		//loading height value
	str	w9, [x8, height_s]			//returning height value to caller

	ldr	w9, [x29, cuboid_s + volume_s]		//loading volume value
	str	w9, [x8, volume_s]			//returning volume value to caller

	ldp	x29, x30, [sp], dealloc			//deallocating memory
	ret						//return to caller

move:
	stp	x29, x30, [sp, -16]!			//allocating memory
	mov	x29, sp					//setting fp to sp

	ldr	w9, [x0, xCoord_s]			//loading x coordinate
	add	w9, w9, w1				//adding desired shift to x coordinate
	str	w9, [x0, xCoord_s]			//storing x coordinate

	ldr	w9, [x0, yCoord_s]			//loading y coordinate
	add	w9, w9, w2				//adding desired shift to y coordinate
	str	w9, [x0, yCoord_s]			//storing y coordinate

	ldp	x29, x30, [sp],16			//deallocating memory
	ret						//return to caller

scale:
	stp 	x29, x30, [sp, -16]!			//allocating memory
	mov	x29, sp					//setting fp to sp

	ldr	w9, [x0, length_s]			//loading length value
	mul	w9, w9, w1				//multiplying length by desired factor
	str	w9, [x0, length_s]			//storing length value

	ldr	w10, [x0, width_s]			//loading width value
	mul	w10, w10, w1				//multiplying width by desired factor
	str	w10, [x0, width_s]			//storing width value

	ldr	w11, [x0, height_s]			//loading height value
	mul	w11, w11, w1				//multiplying height by desired factor
	str	w11, [x0, height_s]			//storing height value

	mul	w12, w9, w10				//length*width=base, stored in w12
	mul	w12, w12, w11				//base*height=volume, stored in w12
	str	w12, [x0, volume_s]			//storing volume value
	
	ldp	x29, x30, [sp], 16			//deallocating memory
	ret						//return to caller

printCuboid:
	stp	x29, x30, [sp, -32]!			//allocating memory
	mov	x29, sp					//setting fp to sp
	mov	x19, x0					//setting x19 to x0

	adrp	x0, fmt					//setting string address
	add	x0, x0, :lo12:fmt			//setting string address
	mov	w1, w1					//setting variables needed to print
	ldr	w2, [x19, xCoord_s]			//loading x coordinate, storing in w2
	ldr	w3, [x19, yCoord_s]			//loading y coordinate, storing in w3
	ldr	w4, [x19, width_s]			//loading width value, storing in w4
	ldr	w5, [x19, length_s]			//loading length value, storing in w5
	ldr	w6, [x19, height_s]			//loading height value, storing in w6
	ldr	w7, [x19, volume_s]			//loading volume value, storing in w7

	bl	printf					//calling printf function

	ldp	x29, x30, [sp], 32			//deallocating memory
	ret						//return to caller

equalSize:
	stp	x29, x30, [sp, -32]!			//allocating memory
	mov	x29, sp					//setting fp to sp

	ldr	w9, [x0, width_s]			//loading width value for cuboid 1
	ldr	w10, [x0, length_s]			//loading length value for cuboid 1
	ldr	w11, [x0, height_s]			//loading height value for cuboid 1

	ldr	w12, [x1, width_s]			//loading width value for cuboid 2
	ldr	w13, [x1, length_s]			//loading length value for cuboid 2
	ldr	w14, [x1, height_s]			//loading height value for cuboid 2

	cmp	w9, w12					//comparing width values
	b.ne	notEqual				//if not equal, jump to notEqual

	cmp	w10, w13				//comparing length values
	b.ne	notEqual				//if not equal, jump to notEqual

	cmp	w11, w14				//comparing height values
	b.ne	notEqual				//if not equal, jump to notEqual

	mov	w0, True				//return true value if all values are equal
	bl	next					//branch to next (to skip notEqual)

notEqual:
	mov	w0, False				//if one or more values are not equal, return false

next:
	ldp	x29, x30, [sp], 32			//deallocate memory
	ret						//return to caller

main:
	stp	x29, x30, [sp, alloc]!			//allocate memory
	mov	x29, sp					//setting fp to sp

	add	x8, x29, first_s			//add fp and address of first cuboid, store in x8
	bl	newCuboid				//make first cuboid

	add	x8, x29, second_s			//add fp and address of second cuboid, store in x8
	bl	newCuboid				//make second cuboid

	adrp	x0, fmt2				//address of string
	add	x0, x0, :lo12:fmt2			//address of string
	bl	printf					//calling printf function

	add	x0, x29, first_s			//add fp and address of first cuboid, store in x0
	ldr	w1, =first				//load "First" string
	bl	printCuboid				//print first cuboid values

	add	x0, x29, second_s			//add fp and address of second cuboid, store in x0
	ldr	w1, =second				//load "Second" string
	bl	printCuboid				//print second cuboid values

	add	x0, x29, first_s			//add fp and address of first cuboid. store in x0
	add	x1, x29, second_s			//add fp and address of second cuboid, store in x1
	bl	equalSize				//call equalSize to determine if the cuboids are equal in size
	cmp	w0, True				//seeing if result from equalSize was true or not

	b.ne else					//if not equal size, skip to else

	add	x0, x29, first_s			//add fp and address of first cuboid, store in x0
	mov	w1, 3					//store 3 in w1 (to shift cuboid 3 to the right)
	mov	w2, -6					//store -6 in w2 (to shift cuboid -6 down_
	bl	move					//call move subroutine to shift the first cuboid

	add	x0, x29, second_s			//add fp and address of second cuboid, store in x0
	mov	w1, 4					//store 4 in w1 (factor of 4 to scale cuboid by)
	bl 	scale					//call scale subroutine to scale the second cuboid

else:
	adrp	x0, fmt3				//address of string
	add	x0, x0, :lo12:fmt3			//address of string
	bl	printf					//calling printf function

	add	x0, x29, first_s			//adding fp and address of first cuboid
	ldr	w1, =first				//loading "First" string into w1
	bl	printCuboid				//calling printCuboid subroutine to print first cuboid values

	add	x0, x29, second_s			//adding fp and address of second cuboid
	ldr	w1, =second				//loading "Second" string into w1
	bl	printCuboid				//calling printCuboid subroutine to print second cuboid values

exit:
	ldp	x29, x30, [sp], dealloc			//deallocating memory
	ret						//return to OS
