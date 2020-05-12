.include "miniprojectUtils.asm"
#TODO: see at end of file
#TODO: document
#TODO: User IO

main:
.data
	string: .space 100
	solved_string: .space 100
	length: .word 0      	# len(str)
	loop_limit: .word 0 	# limit on looping
	isOdd: .word 0  		# Flag if length%2 == 1
	i: .word 0				# counter for string
	i1: .word 0				# counter for solved_string
	immediate: .word 0		# for wordy purpose

.text

#Step 1: get a cyclone string (solved_string)

#Initialize
	getStringDialog(string)
	getLengthLabel(string)
	sw $v0, length 			# v0 = len(str)

	div $t0,$v0, 2 
	sw $t0, loop_limit  
	                   
	rem $t0,$v0, 2
	sw $t0, isOdd
	

#For-ing

.macro init_1
	sw $zero, i
.end_macro

.macro cond_1
	pushRegister($t0)
	pushRegister($t1)

	lw $t0, i
	lw $t1, loop_limit

	slt $v0, $t0, $t1

	popRegister($t1)
	popRegister($t0)
.end_macro

.macro increment_1
	increaseBy1(i)
.end_macro


.macro body_1
	pushRegister($a0)
	pushRegister($a1)
	pushRegister($t0)
	pushRegister($t1)

	getAddressAtIndex(string, i)
	move $a1,$a0   						   #a1 = string[i]

	getAddressAtIndex(solved_string, i1)   #a0 = & solved[i1]

	copyChar($a0, $a1)

	increaseBy1(i1)

	#Get reflect of i
	
	lw $t0, i
	mul $t0,$t0,-1

	lw $t1, length
	addi $t1, $t1, -1

	add $t0, $t1, $t0  						#t0 = len(str) - 1 - i
	sw $t0, immediate

	getAddressAtIndex(string, immediate)
	move $a1,$a0   

	getAddressAtIndex(solved_string, i1)    #a0 = & solved[i1]

	copyChar($a0, $a1)

	increaseBy1(i1)

	popRegister($t1)
	popRegister($t0)
	popRegister($a1)
	popRegister($a0)
	
	
.end_macro

	forLoop(init_1, cond_1, increment_1, body_1)

	lw $t0, isOdd
	beqz $t0, okay

	#Copy middle char
	getAddressAtIndex(string, i)
	move $a1,$a0

	getAddressAtIndex(solved_string, i1)
	copyChar( $a0, $a1)

okay:
	#Print
	printLabel(solved_string)

# Step 2: Check condition ( ord(i) > ord(i+1) )
