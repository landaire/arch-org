.data
	name: .asciiz "Lander Brandt"

.text
	main:
		la $a0, name
		jal print_string

		addi $t0, $v0, 0

		;# Print the string length
		;li $v0, 1
		;addi $a0, $t0, 0
		;syscall

		li $v0, 10
		syscall

	print_string:
		lb $t1, ($a0)
		beq $t1, 0, print_string_done

		# Load the byte we're supposed to print
		lb $t0, ($a0)

		# Store the return address to the stack
		addi $sp, -8
		sw $ra, 0($sp)
		sw $t0, 4($sp)

		# Increment the pointer for the string
		addi $a0, $a0, 1

		jal print_string

		# Restore the return address and byte we print
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		# Restore the stack
		addi $sp, 8

		li $a0, 0
		addi $a0, $t0, 0
		li $v0, 11
		syscall

		print_string_done:
			jr $ra


	strlen:
		li $t0, 0  # Initialize the counter to 0
		li $v0, 0

		loop:
			lb $t1, ($a0)
			beq $t1, 0, done # If we've hit a null byte, end of string

			addi $t0, $t0, 1 # Increment the count
			addi $a0, $a0, 1 # Increment the string address
			b loop # Next iteration

		done:
			addi $v0, $t0, 0
			jr $ra
