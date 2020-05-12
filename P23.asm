.include "miniprojectUtils.asm"
#TODO: User IO, validate

main:

.data
	string: .space 100
	length: .word 0
	i: .word 0
	last_gap: .word -1
	intermediate: .word 0           # for other functions
	isValid: .word 1
.text

	#Initialize
	getStringDialog(string)
	getLengthLabel(string)
	sw $v0, length  	#length = len(string)
	
# For loop

.macro init_1
	sw $zero, i
.end_macro

.macro cond_1
	pushRegister($t0)
	pushRegister($t1)

	lw $t0, i
	lw $t1, length
	addi $t1, $t1, -1

	#Range i := 0, len(str) - 2

	slt $v0, $t0, $t1

	popRegister($t1)
	popRegister($t0)
.end_macro

.macro increment_1
	increaseBy1(i)
.end_macro

.macro body_1
	pushRegister($t9)

	getAddressAtIndex(string, i)
	move $a1,$a0  							# a1 = &str[i]

	# intermediate = i + 1
	lw $t9, i
	addi $t9, $t9, 1
	sw $t9, intermediate

	getAddressAtIndex(string, intermediate)  # a0 = &str[i+1]
	getCharDistance($a1, $a0) 				 # ----> v0

	#Compare to last_gap to check
	# if gap is strictly increasing

	lw $t9, last_gap

	sgt $t9, $v0, $t9 						 # current_gap > last_gap?
	beq $t9, 1, okay

notOkay:
	sw $zero, isValid
	j end

okay:
	j end
	
end:
	sw $v0, last_gap 						 # last_gap = current_gap
	popRegister($t9)

.end_macro

forLoop(init_1, cond_1, increment_1, body_1)

li $v0,1
lw $a0, isValid
syscall
