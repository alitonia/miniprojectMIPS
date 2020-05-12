#Filename: 	miniprojectUtils.asm
#Purpose: 	define utilities which will be used in miniprojects
#Author:	 	Nguyen Huy Hoang	20184265
#       	 	Phi Hoang Long   	  	20184288
#		 	Le Ba Vinh       		20184331
#
#Subprogram index:
#        		abort
#        		checkValidNatural
#        		copyChar
#        		forLoop
#        		getAddressAtIndex
#        		getCharDistance
#        		getIntDialog
#        		getLengthRegister
#        		getLengthLabel
#        		getOrdinal
#        		getStringDialog
#        		increaseBy1
#        		popRegister
#        		printInt
#        		printLabel
#        		printLiteral
#        		pushRegister

#Subprogram: 	abort
#purpose: 	  	print abort string to console
#input:       		none
#output: 	  		none
#side effects: 		exit program

.macro abort()
	printLiteral("\nInvalid input\n")
	printLiteral("Exiting......\n")
	li $v0,10
	syscall
.end_macro

#Subprogram:  	checkValidNotNegative
#purpose: 	  	only accept non-negative or empty input 
#input:       		%value - register contains value 
#             			%status - register contains status
#output: 	  		none
#side effects: 		none

.macro checkValidNotNegative(%value, %status)
	pushRegister($t0)
	pushRegister($t1)
	pushRegister($t2)

	move $t0,%value  		# t0 = value
	move $t1,%status 		# t1 = status

	seq $t2, $t1, $zero 		# status = 0?
	beqz $t2, not_okay

	sge $t2, $t0, 0     		# value >= 0 ?
	beqz $t2, not_okay

	j okay
not_okay:
	abort()
	j end_check
okay:

end_check:
	popRegister($t2)
	popRegister($t1)
	popRegister($t0)
.end_macro

#Subprogram:  	copyChar
#purpose: 	  	duplicate a character from a register to another
#input:       		%source - register to be duplicated
#                		%destination - register to duplicate to
#output: 	  		%destination contains a duplicated character from %source
#side effects: 		none

.macro copyChar(%source, %destination)
	pushRegister($t9)
	lb $t9, (%source)
	sb $t9, (%destination)
	popRegister($t9)
.end_macro

#Subprogram:  	forLoop
#purpose: 	  	C-style for-loop
#input:       		%init - function (.macro) contains initial value source code
#             			%cond - function (.macro) contains condition source code
#             			%increment - function (.macro) contains increment index source code
#            			%body - function (.macro) contains source code for looping 
#output: 	  		indeterminate
#side effects: 		none

.macro forLoop(%init, %cond, %increment, %body)
    	%init
    	
loop:
	pushRegister($v0)

condition: 	
	#result -----> $v0 (0/1)
	#ìf $v0 = 0 , goto end_loop
    	%cond
	beqz $v0, end_loop
	popRegister($v0)

action:
	%body

increment:
	%increment
	j loop

end_loop:
	popRegister($v0)

.end_macro

#Subprogram:  	getAddressAtIndex
#purpose: 	  	find address of an element in array
#input:       		%str - label contains string input
#             			%index - label contains 
#output: 	  		$a0 contains address result
#side effects: 		none

.macro getAddressAtIndex(%str, %index) 
	# $a0 = & %str[%register]
	pushRegister($t0)
	lw $t0, %index
	la $a0, %str
	add $a0, $a0, $t0
	popRegister($t0)

.end_macro

#Subprogram:  	getCharDistance
#purpose: 	  	find the difference in ASCII table of 2 registers, each of which contain a character
#input:       		%register_1 - first register
#             			%register_2 - second register 
#output: 	  		$v0 = abs(%register_1 - % register)
#side effects: 		none

.macro getCharDistance(%register_1, %register_2)
	pushRegister($t0)
	pushRegister($t1)
	lb $t0, (%register_1)
	lb $t1, (%register_2)
	sub $t0, $t0, $t1
	abs $v0, $t0  
	popRegister($t1)
	popRegister($t0)
.end_macro

#Subprogram:  	getIntDialog
#purpose: 	 	get integer input using a dialog
#input:      	 	%label - input label
#             			%message - message label
#output: 	  		%label contains input value
#side effects: 		none

.macro getIntDialog(%label, %message)
    	# int ---> %label
    	# status --> v1
    	# if bad status ---> abort?
    	pushRegister($a0)
    	pushRegister($a1)
    	pushRegister($v0)

    	#Print message dialog 
    	li $v0,51
    	la $a0, %message
    	syscall

    	#Check valid input
    	checkValidNotNegative($a0, $a1)

   	sw $a0, %label
    	move $v1,$a1
	
    	popRegister($v0)
    	popRegister($a1)
    	popRegister($a0)

.end_macro

#Subprogram:  	getLengthRegister
#purpose: 	  	find the length of a string in a register
#input:       		%register - register contains string
#output: 	  		$v0 = length
#side effects: 		none

.macro getLengthRegister(%register)
   	#Get length of string in $1 to $v0
   	pushRegister($a0)
  	pushRegister($t1)
  	pushRegister($t2)

__get_length__:
	move $a0, %register
	#set $v0 = length = 0
	xor $v0, $zero $zero		

__check_char__:
	add $t1, $a0, $v0			    	# t1 = &x[i]  =  a0 + t0							
	lb $t2, 0($t1)				    	# t2 = x[i]
	beq $t2, $zero, __end_of_str__	# if (x[i] == null) break
	addi $v0, $v0, 1			    	# length++
	j __check_char__

__end_of_str__:
__end_of_get_length__:
	addi $v0, $v0, 0			   	 # correct length to saved register
	popRegister($t2)
	popRegister($t1)
	popRegister($a0)

.end_macro

#Subprogram:  	getLengthLabel
#purpose: 	  	find the length of a label that contains a string
#input:       		%label - input label
#output: 	  		$v0 = length
#side effects:		 none

.macro getLengthLabel(%label)
	pushRegister($a0)
	la	$a0, %label
	getLengthRegister($a0)
	popRegister($a0)
.end_macro

#Subprogram:  	getOrdinal
#purpose: 	  	find ASCII value of a character
#input:       		%address - input register that contains a character
#output: 	  		$v0 - ASCII value of the character
#side effects: 		none

.macro getOrdinal(%address)
	lw $v0, %address
.end_macro

#Subprogram:  	getStringDialog
#purpose: 	  	get string input using a dialog
#input:       		%label - input label
#output: 	  		%label contains input value
#side effects: 		none

.macro getStringDialog(%label)
	pushRegister($v0)
	pushRegister($a0)
	pushRegister($a1)
	pushRegister($a2)

.data 
	message: .asciiz "Please input a string: "

.text
	la $a0, message
	la $a1, %label
	li $a2, 100
	li $v0, 54
	syscall

	getLengthLabel(%label)

	la $a0, %label
	add $a0, $a0, $v0
	addi $a0, $a0, -1

	sb $zero, 0($a0)

	popRegister($a2)
	popRegister($a1)
	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:  	increaseBy1
#purpose: 	  	print abort string to console
#input:       		%label - input register
#output: 	  		%label++
#side effects: 		none

.macro increaseBy1(%label)
	pushRegister($t9)
	lw $t9, %label
	addi $t9, $t9, 1
	sw $t9, %label
	popRegister($t9)
.end_macro

#Subprogram:  	popRegister
#purpose: 	 	 pop from stack
#input:       		%register
#output: 	  		$sp is popped into %register
#side effects: 		none

.macro popRegister(%register)
	lw %register, 0($sp)
	addi $sp, $sp, 4
.end_macro

#Subprogram:  	printInt
#purpose: 	  	print integer from a label
#input:       		%label
#output: 	  		print to console
#side effects: 		none

.macro printInt(%label)

    	pushRegister($v0)
    	pushRegister($a0)

   	li $v0,1
    	lw $a0, %label
    	syscall

    	popRegister($a0)
    	popRegister($v0)

.end_macro

#Subprogram:  	printLabel
#purpose: 	  	print string from a label
#input:       		%label
#output: 	  		print to console
#side effects: 		none

.macro printLabel(%label)

    	pushRegister($v0)
   	pushRegister($a0)

	li	$v0, 4
	la	$a0, %label
	syscall

	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:  	printLiteral
#purpose: 	  	print out a string to console
#input:       		%string - string to print out
#output: 	  		print to console
#side effects: 		none

.macro printLiteral(%string)

.data
	__string__: .asciiz %string
.text
	pushRegister($v0)
	pushRegister($a0)

	li $v0, 4
	la $a0, __string__
	syscall

	popRegister($a0)
	popRegister($v0)

.end_macro

#Subprogram:  	 pushRegister
#purpose: 	 	 push a register into stack
#input:       	 	%register - register to push
#output: 	  		$sp with new peek %register
#side effects: 		none

.macro pushRegister(%register)
	addi $sp, $sp, -4
	sw %register, 0($sp)
.end_macro 
