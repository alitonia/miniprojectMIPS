

#TODO: see at end of file
#TODO: document
#TODO: User IO


.macro push_reg(%register)
	addi $sp, $sp, -4
	sw %register, 0($sp)
.end_macro 


.macro pop_reg(%register)
	lw %register, 0($sp)
	addi $sp, $sp, 4
.end_macro



.macro print_label(%label)

   #Print the string from label $1
   push_reg($v0)
   push_reg($a0)

	li	$v0, 4
	la	$a0, %label
	syscall

	pop_reg($a0)
	pop_reg($v0)

.end_macro




.macro for_branching(%init, %cond, %increment, %body)

	#Initialize
	%init

loop:
	push_reg($v0)

Condition: # -----> v0
	%cond

	beqz $v0,end_loop

	pop_reg($v0)

action:
	%body


increment:
	%increment
	j loop


end_loop:
	pop_reg($v0)

.end_macro








.macro get_length_reg(%register)

   #Get length of string in $1 to $v0
   push_reg($a0)
   push_reg($t1)
   push_reg($t2)

__get_length__:

	move $a0, %register

	#set zero
	xor $v0, $zero $zero		#v0 = length = 0

__check_char__:
	add $t1, $a0, $v0			# t1 = &x[i]  =  a0 + t0
								
	lb $t2, 0($t1)				# t2 = x[i]

	beq $t2, $zero, __end_of_str__	# if (x[i] == null) break loop

	addi $v0, $v0, 1			# length ++;
	j __check_char__

__end_of_str__:
__end_of_get_length__:

	addi $v0, $v0, 0			#  correct length to saved register
	
	pop_reg($t2)
	pop_reg($t1)
	pop_reg($a0)


.end_macro





.macro get_length_label(%label)

	#Get length of string in $1 to $v0
	push_reg($a0)

	la	$a0, %label
	get_length_reg($a0)

	pop_reg($a0)

.end_macro





.macro get_string_dialog(%label)
	push_reg($v0)
	push_reg($a0)
	push_reg($a1)
	push_reg($a2)

	li $v0, 54
	.data 
		Polite_ask: .asciiz "Please input a string:"
	.text
	la $a0,Polite_ask
	la $a1, %label
	li $a2, 100
	syscall

	get_length_label(%label)

	la $a0, %label
	add $a0, $a0, $v0
	addi $a0, $a0, -1

	sb $zero, 0($a0)


	pop_reg($a2)
	pop_reg($a1)
	pop_reg($a0)
	pop_reg($v0)

.end_macro





.macro get_address_at_index(%str, %index) 
	# a0 = & %str[%register]

	push_reg($t0)
	lw $t0, %index

	la $a0, %str
	add $a0, $a0, $t0

	pop_reg($t0)

.end_macro


.macro copy_char(%register_address_1, %register_address_2)
	push_reg($t9)

	lb $t9, (%register_address_2)
	sb $t9, (%register_address_1)

	pop_reg($t9)
.end_macro


.macro increase_by_1(%label)
	push_reg($t9)

	lw $t9, %label
	addi $t9, $t9, 1
	sw $t9, %label

	pop_reg($t9)

.end_macro





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

#Step 1: get a good string (solved_string)

#Initialize
	get_string_dialog(string)

	get_length_label(string)
	sw $v0, length # v0 = len(str)

	div $t0,$v0, 2 
	sw $t0, loop_limit  
	                   
	rem $t0,$v0, 2
	sw $t0, isOdd
	

#For-ing

.macro init_1
	sw $zero, i
.end_macro


.macro cond_1
	push_reg($t0)
	push_reg($t1)

	lw $t0, i
	lw $t1, loop_limit

	slt $v0, $t0, $t1

	pop_reg($t1)
	pop_reg($t0)
.end_macro


.macro increment_1
	increase_by_1(i)
.end_macro


.macro body_1
	push_reg($a0)
	push_reg($a1)
	push_reg($t0)
	push_reg($t1)


	get_address_at_index(string, i)
	move $a1,$a0   							#a1 = string[i]

	get_address_at_index(solved_string, i1)   #a0 = & solved[i1]

	copy_char($a0, $a1)

	increase_by_1(i1)

	#Get reflect of i
	
	lw $t0, i
	mul $t0,$t0,-1

	lw $t1, length
	addi $t1, $t1, -1

	add $t0, $t1, $t0  # t0 = len(str) - 1 - i
	sw $t0, immediate


	get_address_at_index(string, immediate)
	move $a1,$a0   

	get_address_at_index(solved_string, i1)   #a0 = & solved[i1]

	copy_char($a0, $a1)

	increase_by_1(i1)

	pop_reg($t1)
	pop_reg($t0)
	pop_reg($a1)
	pop_reg($a0)
	
	
.end_macro


for_branching(init_1, cond_1, increment_1, body_1)


lw $t0, isOdd
beqz $t0, not_a_problem

#Copy middle char
get_address_at_index(string, i)
move $a1,$a0

get_address_at_index(solved_string, i1)
copy_char( $a0, $a1)

not_a_problem:

#Print
print_label(solved_string)


# Step 2: Check condition ( ord(i) > ord(i+1) )