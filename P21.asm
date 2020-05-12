
#TODO: Procedure done, need appropriate output

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




.macro digit_sum(%label)
# v0 = sum([i for i in str( %label )])
	push_reg($t0)
	push_reg($t1)
	push_reg($t2)

	#Initialize:
	lw $t0, %label  	# t0 = value of %label
						# t1 = Condition
						# t2 = intermediate
						
	li $v0,0

digit_loop:
#Now inside digit loop
digit_condition:
	sgt $t1, $t0, 0		# t0 > 0?
	beqz $t1,end_digit_loop

digit_action:
	rem $t2, $t0, 10
	add $v0, $v0, $t2  # sum += ( value %10 )
	
	div $t0,$t0, 10		# t0 /= 10

	j digit_loop


end_digit_loop:
	pop_reg($t2)
	pop_reg($t1)
	pop_reg($t0)

.end_macro


.macro print_literal(%string)
.data
	__secret_string__: .asciiz %string
.text
	push_reg($v0)
	push_reg($a0)

	li $v0,4
	la $a0,__secret_string__
	syscall

	pop_reg($a0)
	pop_reg($v0)

.end_macro



.macro Abort()
	print_literal("\nInvalid input\n")
	print_literal("Exiting......\n")

	li $v0,10
	syscall

.end_macro




.macro check_valid(%value, %status)
	push_reg($t0)
	push_reg($t1)
	push_reg($t2)

	move $t0,%value  	# t0 = value
	move $t1,%status 	# t1 = status

	seq $t2, $t1, $zero # status = 0?
	beqz $t2, not_okay

	sge $t2, $t0, 0   # value >= 0 ?
	beqz $t2,not_okay


	j okay
not_okay:
	Abort()
	j end_check
okay:

end_check:
.end_macro



.macro get_int_dialog(%label, %message)
# int ---> %label
# status --> v1

# if bad status ---> abort?

push_reg($a0)
push_reg($a1)
push_reg($v0)

li $v0,51
la $a0, %message
syscall

check_valid($a0, $a1)

sw $a0, %label
move $v1,$a1

pop_reg($v0)
pop_reg($a1)
pop_reg($a0)

.end_macro



.macro print_int(%label)
push_reg($v0)
push_reg($a0)

li $v0,1
lw $a0, %label

syscall

pop_reg($a0)
pop_reg($v0)

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
	initial_value: .word 0
	order: .word 0

	please_input: .asciiz "Please input a valid number: "
.text

	get_int_dialog(initial_value, please_input)
#	print_int(initial_value)


while:

while_condition:
	lw $v0, initial_value
	sge $t0, $v0, 10	# initial_value >= 10 ?
	beqz $t0,end_while

while_action:
	digit_sum(initial_value)
	sw $v0, initial_value	# initial_value = sum( [i for i in str(initial_value)])

	increase_by_1(order)
	j while
	
	
end_while:

	print_int(order)
