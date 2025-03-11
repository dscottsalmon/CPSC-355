//File: a5b.asm
//Authors: Scott Salmon UCID - 30093320

//Description: A program written in Assembly language that takes two command line arguments in the form
//"mm dd" and converts them into the name of the month, the date (with the appropiate suffix) and the
//season correlated with said date.

	define(argc, w23)			//number of arguments
	define(argv, x24)			//arguments array

	define(month, w19)			//user input for month
	define(day, w20)			//user input for day
	define(season, w21)			//determined season

	define(month_r, x22)			//base address for month array
	define(suffix_r, x23)			//base address for suffix array
	define(season_r, x25)			//base address for season array

	.text
usage:	.string "usage: a5b mm dd\n"		//improper input error message
result:	.string "%s %d%s is %s\n"		//proper input result message

jan:	.string "January"			//strings for each month
feb:	.string "February"
mar:	.string "March"
apr:	.string "April"
may:	.string "May"
jun:	.string "June"
jul:	.string "July"
aug:	.string "August"
sep:	.string "September"
oct:	.string "October"
nov:	.string "November"
dec:	.string "December"

th:	.string	"th"				//strings for each suffix
st:	.string "st"
nd:	.string "nd"
rd:	.string "rd"

win:	.string "Winter"			//strings for each season
spr:	.string "Spring"
sum:	.string "Summer"
fal:	.string "Fall"

month_m:	.dword jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec	//array for each month
suffix_m:	.dword st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st	//array for each suffix
season_m:	.dword win, spr, sum, fal	//array for each season
	
	.balign 4				//aligned by 4 bytes
	.global main
main:
	stp	fp, lr, [sp, -16]!		//allocating memory
	mov	fp, sp				//setting fp to sp

	mov	argc, w0			//storing argc
	mov	argv, x1			//storing argv

	mov	w25, 1
	mov	w26, 2

	cmp	argc, 3				//checking length of arguments
	b.ne	err				//if argument not equal to 3 (i.e. more or less than 2
						//numbers entered, error code is launched
conti1:
	ldr	x0, [argv, w25, sxtw 3]		//loads first element (i.e. month input) into x0
	bl 	atoi				//converts this string into integer
	mov	month, w0			//moves month integer into month variable

	cmp	month, 0			//checks if month is less than 0
	b.le	err				//if so, launch error
	cmp	month, 12			//checks if month is greater then 12
	b.gt	err				//if so, launch error

	ldr	x0, [argv, w26, sxtw 3]		//loads second element (i.e. day input) into x0
	bl	atoi				//converts this string into integer
	mov	day, w0				//moves day integer into day variable

	cmp	day, 0				//checks if day is less than 0
	b.le	err				//if so, launch error
	cmp	day, 31				//checks if day is greater than 31
	b.gt	err				//if so, launch error

	cmp	month, 4			//compares month value and 4
	b.lt	setWinter			//if month is less than 4, jump to setWinter
	cmp	month, 7			//comapares month value and 7
	b.lt	setSpring			//if month is less than 7, jump to setSpring
	cmp	month, 10			//compares month value and 10
	b.lt	setSummer			//if month is less than 10, jump to setSummer
	cmp	month, 13			//compares month value and 13
	b.lt	setFall				//if month is less than 13, jump to setFall

setWinter:
	mov	season, 0			//sets season to 0 (i.e. Winter)
	cmp	month, 3			//checks to see if month 3 (i.e. March)
	b.ne	output				//if month is NOT 3 (i.e. Jan, Feb, Dec), jump to output
	cmp 	day, 21				//checks if day is greater than 21
	b.gt	increase			//if so, then month is march and day is 22+ so jump to increase
	b	output				//if not, then month is march and day is 21-, so jump to output

setSpring:
	mov	season, 1			//sets season to 1 (i.e. Spring)
	cmp	month, 6			//checks to see if month is 6 (i.e. June)
	b.ne	output				//if month is NOT 6 (i.e. March, April, May), jump to output
	cmp	day, 21				//checks if day is greater than 21
	b.gt	increase			//if so, then month is June an day is 22+, so jump to increase
	b	output				//if not, then month is June and day is 21-, so jump to output

setSummer:
	mov	season, 2			//sets season to 2 (i.e. Summer)
	cmp	month, 9			//checks to see if month is 9 (i.e. Septemer)
	b.ne	output				//if month is NOT 9 (i.e. June, July, August), jump to output
	cmp	day, 21				//checks if day is greater than 21
	b.gt	increase			//if so, then month is September and day is 22+, so jump to increase
	b	output				//if not, then month is September and day is 21-, so jump to output

setFall:
	mov	season, 3			//sets season to 3 (i.e. Fall)
	cmp	month, 12			//checks to see if month is 12 (i.e. December)
	b.ne	output				//if month is NOT 12 (i.e. September, October, November), jump to output
	cmp	day, 21				//checks if day is greater than 21
	b.gt	increase			//if so, then month is December and day is 22+, so jump to increase
	b	output				//if not, then month is December and day is 21-, so jump to output

increase:
	add	season, season, 1		//increases season by 1
	cmp	season, 4			//if season is 4, jump back to setWinter where it'll get set back to 0
	b.eq	setWinter			//explained above
	b	output				//jump to output

err:
	adrp	x0, usage			//loading address for
	add	x0, x0, :lo12:usage		//error code string
	bl	printf				//calls printf function
	b	end				//jumps to end

output:
	adrp	month_r, month_m		//loading month array address
	add	month_r, month_r, :lo12:month_m //for month string
	sub	month, month, 1			//subtracts 1 from input

	adrp	suffix_r, suffix_m		//loading suffix array address
	add	suffix_r, suffix_r, :lo12:suffix_m //for month string

	adrp	x0, result			//loading address for
	add	x0, x0, :lo12:result		//result string

	ldr	x1, [month_r, month, sxtw 3]	//loads month value into x1

	mov	w2, day				//moves day value into w2
	sub	day, day, 1			//decreases the day by 1
	ldr	x3, [suffix_r, day, sxtw 3]	//loads suffix value into x3

	adrp	season_r, season_m		//loading season array address
	add	season_r, season_r, :lo12:season_m //for season string
	ldr	x4, [season_r, season, sxtw 3]	//loading season value into x4

	bl	printf				//cals printf
	
end:	
	ldp	fp, lr, [sp],16			//deallocating memory
	ret					//return to OS

