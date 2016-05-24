.data
	tcb: .space 256
	tid: .word 1
	task0_hello: .asciiz "Hello from task 0\n"
	task1_hello: .asciiz "Hello from task 1\n"
	task2_hello: .asciiz "Hello from task 2\n"

.text
main:
	# Initialization:
	li $a0, 0
	jal task_tcb_address
	addi $t0, $v0, 0 # $t0 is this task's control block

	la $t1, task0
	sw $t1, 0($t0)
	li $t1, 0
	sw $t1, 4($t0)

	li $a0, 1
	jal task_tcb_address
	addi $t0, $v0, 0 # $t0 is this task's control block

	la $t1, task1
	sw $t1, 0($t0)
	li $t1, 0
	sw $t1, 4($t0)

	li $a0, 2
	jal task_tcb_address
	addi $t0, $v0, 0 # $t0 is this task's control block

	la $t1, task2
	sw $t1, 0($t0)
	li $t1, 0
	sw $t1, 4($t0)

	j task0

exit:
	li $v0, 10
	syscall

task_tcb_address:
	addi $t3, $a0, 0

	la $t4, tcb

	li $t5, 11 # up to 9 temp registers + 1 return address + 1 word process state
	li $t6, 4
	mult $t5, $t6 # multiply by 4 for the word size
	mflo $t5

	mult $t5, $t3 # multiply by the task ID to get the offset in the tcb
	mflo $t5

	add $t4, $t4, $t5 # $t4 is now the offset of this task ID's part of the TCB

	addi $v0, $t4, 0
	jr $ra

task_switch:
	addi $t0, $ra, 0 # $t0 represents the return address
	addi $t1, $a0, 0 # $t1 represents the task ID
	addi $t2, $a1, 0 # $t1 represents the process state

	addi $a0, $t1, 0
	jal task_tcb_address
	addi $t4, $v0, 0

	sw $t0, 0($t4)
	sw $t2, 4($t4)

	addi $t4, $t4, 8

	li $t6, 0
	task_switch_save_register_loop:
		beq $t6, 9, task_switch_save_register_loop_exit # 9 registers on the stack

		lw $t7, 0($sp)
		sw $t7, 0($t4)

		addi $sp, $sp, 4
		addi $t4, $t4, 4

		addi $t6, $t6, 1
		j task_switch_save_register_loop

	task_switch_save_register_loop_exit:
		li $t5, 9 # up to 8 temp registers on the stack, plus one for $ra
		li $t6, -4
		mult $t5, $t6 # multiply by -4 for the word size
		mflo $t5

		add $sp, $sp, $t5 # reset the stack pointer

		li $t6, 0 # checked task count

	task_switcher_get_next_task_loop:
		beq $t6, 3, exit

		addi $t1, $t1, 1 # increment task ID
		li $t5, 3 # task count
		div $t1, $t5
		mfhi $t1 # basically task_id % task_count -- $t3 now represents next task ID

		la $t4, tcb

		addi $sp, $sp, -12
		sw $t4, 0($sp)
		sw $t1, 4($sp)
		sw $t6, 8($sp)

		addi $a0, $t1, 0
		jal task_tcb_address

		lw $t4, 0($sp)
		lw $t1, 4($sp)
		lw $t6, 8($sp)
		addi $sp, $sp, 12

		addi $t4, $v0, 0

		lw $t5, 4($t4) # $t5 is the task state
		beq $t5, 0, task_switcher_get_next_task_loop_exit # 0 represents still running, so we found our desired task

		addi $t6, $t6, 1
		j task_switcher_get_next_task_loop

	task_switcher_get_next_task_loop_exit:
		addi $sp, $sp, -4
		sw $t1, 0($sp)

		addi $a0, $t1, 0
		jal task_tcb_address

		lw $t1, 0($sp)
		addi $sp, $sp, 4

		addi $a0, $t1, 0
		jal task_tcb_address
		addi $t4, $v0, 0 # $t4 is this task's control block

		lw $t0, 0($t4) # $t0 represents the return address

		addi $t4, $t4, 8 # offset + 8 is the start of temp registers

		li $t6, 0 # $t6 is the number of registers restored

	task_switch_restore_register_loop:
		beq $t6, 9, task_switch_restore_register_loop_exit

		lw $t7, 0($t4)
		sw $t7, 0($sp)

		addi $sp, $sp, 4
		addi $t4, $t4, 4

		addi $t6, $t6, 1
		j task_switch_restore_register_loop

	task_switch_restore_register_loop_exit:
		addi $sp, $sp, -36 # reset the stack pointer
		jr $t0 # jump to the return address

task0:
	li $t1, 0
	task0_loop:
		la $t0, task0_hello
		addi $a0, $t0, 0
		li $v0, 4
		syscall

		li $t8, 0
		li $t9, 0

		slt $t2, $t1, 10
		blt $t1, 10, task0_continue
		li $t9, 1
		j task0_loop_next

		task0_continue:
			li $t9, 0

		task0_loop_next:
			jal do_task_switch
			addi $t1, $t1, 1
			j task0_loop

task1:
	la $a0, task1_hello
	li $v0, 4
	syscall

	li $t9, 0
	li $t8, 1

	jal do_task_switch

	la $a0, task1_hello
	li $v0, 4
	syscall

	li $t9, 1
	li $t8, 1
	jal do_task_switch

task2:
	la $a0, task2_hello
	li $v0, 4
	syscall

	li $t9, 0
	li $t8, 2
	jal do_task_switch

	la $a0, task2_hello
	li $v0, 4
	syscall

	li $t9, 1
	li $t8, 2
	jal do_task_switch

do_task_switch:
	addi $sp, $sp, -36 # 8 temp registers, plus $ra
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $ra, 32($sp)

	addi $a0, $t8, 0 # task ID
	addi $a1, $t9, 0 # task state

	jal task_switch

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $ra, 32($sp)

	addi $sp, $sp, 36

	jr $ra
