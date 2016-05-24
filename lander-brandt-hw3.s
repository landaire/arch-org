# Lander Brandt

  .data
  .align 4

array1:  .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
array2: .space 44

  .text
main:
  li $t0, 0
  la $t1, array1
  la $t2, array2

loop:
  # Read/store values
  lw $t3, ($t1)
	# check if it's even of odd
  andi $t4, $t3, 1

  bne $t4, 0, increment_loop

  sw $t3, ($t2)

  addi $t2, 4

increment_loop:
  # Increment load/store addresses by 1
  addi $t1, 4

  addi $t0, 1 # Decrement the counter

  blt $t0, 11, loop

  li $t0, 6
  la $t2, array2

print_loop:
  lw $a0, ($t2)
  li $v0, 1
  syscall

  addi $t2, 4 # Increment the load address
  addi $t0, -1 # Decrement the counter

  bgtz $t0, print_loop

  # Exit
  li $v0, 10
  syscall

