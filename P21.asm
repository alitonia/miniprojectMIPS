.include "miniprojectUtils.asm"

.macro digit_sum(%label)
	
	# v0 = sum([i for i in str( %label )])
	pushRegister($t0)
	pushRegister($t1)
	pushRegister($t2)

	#Initialize:
	lw $t0, %label  			# t0 = value of %label
							# t1 = Condition
							# t2 = intermediate				
	li $v0, 0

digit_loop:
	#Now inside digit loop
	
digit_condition:
	sgt $t1, $t0, 0				# t0 > 0?
	beqz $t1,end_digit_loop

digit_action:
	rem $t2, $t0, 10
	add $v0, $v0, $t2  			# sum += ( value %10 )
	
	div $t0,$t0, 10				# t0 /= 10

	j digit_loop

end_digit_loop:
	popRegister($t2)
	popRegister($t1)
	popRegister($t0)

.end_macro


main:
.data 
	initial_value: .word 0
	order: .word 0
	promptString: .asciiz "Please input a valid number: "
.text
	getIntDialog(initial_value, promptString)

while:

while_condition:
	lw $v0, initial_value
	sge $t0, $v0, 10			# initial_value >= 10 ?
	beqz $t0,end_while

while_action:
	digit_sum(initial_value)
	sw $v0, initial_value		# initial_value = sum( [i for i in str(initial_value)])

	increaseBy1(order)
	j while
	
end_while:
	printInt(order)
