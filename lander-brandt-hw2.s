# Lander Brandt

  .data
enterNum:  .asciiz "Enter number: "
sum: .asciiz "Sum: "
difference: .asciiz "Difference: "
linebreak: .asciiz "\n"

  .text
main:
  # Print "Enter number"
  li $v0, 4
  la $a0, enterNum
  syscall

  # Read the number
  li $v0, 5
  syscall

  # Store the result in a temp var
  move $t0, $v0

  # Prompt them to enter the second number
  li $v0, 4
  la $a0, enterNum
  syscall

  # Read the number
  li $v0, 5
  syscall

  # Store the resulting number
  move $t1, $v0

  # Add num1 and num2
  add $t2, $t0, $t1

  # Print the sum string
  li $v0, 4
  la $a0, sum
  syscall

  # Print the sum
  li $v0, 1
  la $a0, ($t2)
  syscall

  # Print a linebreak
  li $v0, 4
  la $a0, linebreak
  syscall

  # Calculate the difference of num1 - num2
  sub $t2, $t0, $t1

  # Print the difference string
  li $v0, 4
  la $a0, difference
  syscall

  # Print the difference
  li $v0, 1
  la $a0, ($t2)
  syscall

  li $v0, 10
  syscall
