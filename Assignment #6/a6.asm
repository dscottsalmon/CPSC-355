//File: a6.asm
//Author(s): Scott Salmon UCID 30093320
//Date: December 1st-3rd, 2022

//Description: A program written in Assembly language that computes angles given in degrees and 
//converts them into radians, and then computers the sin and cosine of the angle using series expansions.


define(fd, w19)						
define(n_read, x20)
define(buf_base, x21)
define(argc, w22)
define(argv, x23)

buf_size = 8						//memory allocation and buffer
alloc = -(16 + buf_size) & -16
dealloc = -alloc
buf_s = 16

power		.req	d19				//floating point registers used
numerator	.req	d20
factorial	.req	d21
term		.req	d22
accumulator	.req	d23
incr		.req	d24

constant:	.double	0r1.0e-10			//used to stop taylor series loop later
degree:		.double	0r9.0e1				//90 degrees
radian:		.double	0r1.57079632679489661923	//pi/2 radians

header:		.string "Input (degrees):  Input (radians):\tsin(x):\t\tcos(x):\n"	//header string
values:		.string "%13.10f\t %13.10f\t\t%13.10f\t%13.10f\n"			//value string
error:		.string "Error!"							//error string


	.global main				//sets main as global method
	.balign 4				//aligns by 4 bytes
main:
	stp	x29, x30, [sp, alloc]!		//allocates memory
	mov	x29, sp				//sets fp to sp

	mov	argc, w0			//moves number of arguments to w0
	mov	argv, x1			//arguments array moved to x1
	cmp	argc, 2				//checking number of arguments
	b.ne	err				//if more or less than 1 argument, print error

	adrp	x0, header			//loading header string
	add	x0, x0, :lo12:header		//^^^^^
	bl	printf				//calling printf

	mov	w0, -100			//1st arg (use cwd)
	ldr	x1, [argv,8]			//2nd arg (pathname)
	mov	w2, 0				//3rd arg (read-only)
	mov	w3, 0				//4th arg (not used)
	mov	w8, 56				//openat I/O request
	svc	0				//call system function
	mov	fd, w0				
	cmp	fd, 0				//error check
	b.ge	openok				//if fd >= 0, jump to openok

err:
	adrp	x0, error			//loading error string
	add	x0, x0, :lo12:error		//^^^
	bl	printf				//calling printf function
	mov	w0, -1				//sets w0 to -1
	b	done				//branch to done

openok:
	add	buf_base, x29, buf_s		//adds fp to buf_s (16), and stores in buf_base

top:
	mov 	w0, fd				//1st arg (fd)
	mov	x1, buf_base			//2nd arg
	mov	w2, buf_size			//3rd arg (n)
	mov	x8, 63				//read I/O request
	svc	0				//call sys function
	mov	n_read, x0			//stores x0 in n_read

	cmp	n_read, buf_size		//compares n_read to buf_size
	b.ne	endFile				//if not equal, skip to endFile

	adrp	x24, degree			//loads 90 degrees
	add	x24, x24, :lo12:degree		//^^^
	ldr	d5, [x24]			//stores 90.0 in d5

	ldr	d0, [buf_base]			//load in d0 (x)
	fcmp	d0, 0.0				//compares d0 to 0.0
	b.lt	endFile				//if x < 0, skip to endFile
	fcmp	d0, d5				//compares d0 to 90.0
	b.gt	endFile				//if x > 90, skip to endFile

	adrp	x25, radian			//load in radian constant
	add	x25, x25, :lo12:radian		//^^^^
	ldr	d6, [x25]			//stores radian constant (1.57...) in d6

	fdiv	d0, d0, d5			//x/90.0 = % of 90 degrees x is
	fmul	d0, d0, d6			//% * (pi/2) = number of radians
	fmov	d1, d0				//store number of radians in d1

	bl	sin				//branchs to sin subroutine
	fmov	d2, d0				//moves result into d2

	bl	cos				//branches to cos subroutine
	fmov	d3, d0				//moves result into d3

	adrp	x0, values			//loads values string
	add	x0, x0, :lo12:values		//^^^^
	ldr	d0, [buf_base]			//resets d0 to input in degrees
	bl	printf				//branches to printf

	b	top				//repeats top until out of input

endFile:
	mov	w0, fd				//1st arg (fd)
	mov	x8, 57				//close I/O request
	svc	0				//call sys function
	mov	w0, 0				//status is in w0

done:
	ldp	x29, x30, [sp], dealloc		//deallocates memory
	ret					//return to OS

	.balign 4				//aligned by 4 bytes
	.global sin				//sets sin as a global subroutine
sin:
	stp	x29, x30, [sp, -16]!		//allocates memory
	mov	x29, sp				//sets fp to sp

	adrp	x22, constant			//loads constant value
	add	x22, x22, :lo12:constant	//^^^^
	ldr	d5, [x22]			//stores constant value in d5

	fmov	incr, 1.0			//sets incr to 1.0
	fmov	power, 3.0			//sets power to 3.0
	fmov	factorial, 6.0			//3! = 3 * 2 * 1 = 6
	fmov	accumulator, d1			//first term of accumulator = x
	fmov	numerator, d1			//sets numerator = x
	fmul	numerator, numerator, d1	//numerator = x * x = x^2
	fmul	numerator, numerator, d1	//numerator = x^2 * x = x^3
	fdiv	term, numerator, factorial	//x^3/3!
	fsub	accumulator, accumulator, term	//x - (x^3/3!)
	b	loop				//branch to loop

	.balign 4				//aligned by 4 bytes
	.global cos				//sets cos as a global subroutine
cos:
	stp	x29, x30, [sp, -16]!		//allocates memory
	mov	x29, sp				//sets fp to sp

	adrp	x22, constant			//loads constant value
	add	x22, x22, :lo12:constant	//^^^
	ldr	d5, [x22]			//stores constant value in d5

	fmov	incr, 1.0			//sets incr to 1.0
	fmov	power, 2.0			//sets power to 2.0
	fmov	factorial, 2.0			//2! = 2 * 1 = 2
	fmov	accumulator, 1.0		//first term of accumulator = 1
	fmov	numerator, 1.0			//sets numerator = 1.0
	fmul	numerator, numerator, d1	//numerator = 1.0 * x = x
	fmul	numerator, numerator, d1	//numerator = x * x = x^2
	fdiv	term, numerator, factorial	//x^2/2!
	fsub	accumulator, accumulator, term	//1.0 - (x^2/2!)

loop:
	fmul	numerator, numerator, d1	//increases power of numerator by 1
	fmul	numerator, numerator, d1	//increases power of numerator by 1
	fadd	power, power, incr		//increases "power" by 1
	fmul	factorial, factorial, power	//increases factorial by 1
	fadd	power, power, incr		//increases "power" by 1
	fmul	factorial, factorial, power	//increases factorial by 1
	fdiv	term, numerator, factorial	//numerator/factorial
	fadd	accumulator, accumulator, term	//adds new term to total

	fmul	numerator, numerator, d1	//increases power of numerator by 1
	fmul	numerator, numerator, d1	//increases power of numerator by 1
	fadd	power, power, incr		//increases "power" by 1
	fmul	factorial, factorial, power	//increases factorial by 1
	fadd	power, power, incr		//increases "power" by 1
	fmul	factorial, factorial, power	//increases factorial by 1
	fdiv	term, numerator, factorial	//numerator/factorial
	fsub	accumulator, accumulator, term	//subtracts new term from total

	fabs	term, term			//finds magnitude of most recent term
	fcmp	term, d5			//compares term to constant saved earlier
	b.ge	loop				//if term >= constant, loop again

	fmov	d0, accumulator			//return accumulator value
	ldp	x29, x30, [sp], 16		//deallocate memory
	ret					//return to caller
