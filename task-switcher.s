.data
.align 2
	tcb: .space 512
	tid: .word 1
	task0_hello: .asciiz "Hello from task 0\n"
	task1_hello: .asciiz "Hello from task 1\n"
	task2_hello: .asciiz "Hello from task 2\n"

	TCB_TOTAL_REGISTER_COUNT = 26
	TCB_WORD_COUNT = TCB_TOTAL_REGISTER_COUNT
	TASK_COUNT = 3

str0:   .asciiz "123"
str1:   .asciiz "45678"

.text
main:
	# Initialization:
	la $t0, tid
	li $t1, 0
	sw $t1, 0($t0)

	li $a0, 0
	jal task_tcb_address
	addi $t0, $v0, 0 # $t0 is this task's control block

	la $t1, ktask0
	sw $t1, 0($t0)

	li $a0, 1
	jal task_tcb_address
	addi $t0, $v0, 0 # $t0 is this task's control block

	la $t1, ktask1
	sw $t1, 0($t0)

	li $a0, 2
	jal task_tcb_address
	addi $t0, $v0, 0 # $t0 is this task's control block

	la $t1, task2
	sw $t1, 0($t0)

	j ktask0

exit:
	li $v0, 10
	syscall

task_tcb_address:
	addi $t3, $a0, 0

	la $t4, tcb

	li $t5, TCB_WORD_COUNT
	li $t6, 4
	mult $t5, $t6 # multiply by 4 for the word size
	mflo $t5

	mult $t5, $t3 # multiply by the task ID to get the offset in the tcb
	mflo $t5

	add $t4, $t4, $t5 # $t4 is now the offset of this task ID's part of the TCB

	addi $v0, $t4, 0
	jr $ra

task_switch:
	la $t1, tid
	lw $t1, 0($t1) # this represents the task ID

	addi $a0, $t1, 0
	jal task_tcb_address
	addi $t4, $v0, 0

	addi $t9, $sp, 0

	li $t6, 0
	task_switch_save_register_loop:
		beq $t6, TCB_TOTAL_REGISTER_COUNT, task_switch_save_register_loop_exit # save all the temp registers now

		lw $t7, 0($sp)
		sw $t7, 0($t4)

		addi $sp, $sp, 4
		addi $t4, $t4, 4

		addi $t6, $t6, 1
		j task_switch_save_register_loop

	task_switch_save_register_loop_exit:
		addi $sp, $t9, 108

		# Figure out the next task
		addi $t1, $t1, 1 # increment task ID
		li $t5, TASK_COUNT # task count
		div $t1, $t5
		mfhi $t1 # basically task_id % task_count -- $t3 now represents next task ID

		la $t6, tid
		sw $t1, 0($t6)

		addi $a0, $t1, 0
		jal task_tcb_address
		addi $t9, $v0, 0 # $t4 is this task's control block

		lw $ra, 0($t9) # restore the return address

		addi $t9, $t4, 4 # offset + 8 is the start of the rest of the registers

		lw $2, 0($t9)
		lw $3, 4($t9)
		lw $4, 8($t9)
		lw $5, 12($t9)
		lw $6, 16($t9)
		lw $7, 20($t9)
		lw $8, 24($t9)
		lw $9, 28($t9)
		lw $10, 32($t9)
		lw $11, 36($t9)
		lw $12, 40($t9)
		lw $13, 44($t9)
		lw $14, 48($t9)
		lw $15, 52($t9)
		lw $16, 56($t9)
		lw $17, 60($t9)
		lw $18, 64($t9)
		lw $19, 68($t9)
		lw $20, 72($t9)
		lw $21, 76($t9)
		lw $22, 80($t9)
		lw $23, 84($t9)
		lw $24, 88($t9)
		lw $30, 92($t9)
		lw $26, 96($t9)
		lw $27, 100($t9)

		jr $ra# jump to the return address

task0:
	li $t1, 0
	task0_loop:
		la $t0, task0_hello
		addi $a0, $t0, 0
		li $v0, 4
		syscall

		slt $t2, $t1, 10

		task0_loop_next:
			jal do_task_switch
			addi $t1, $t1, 1
			j task0_loop

task1:
	la $a0, task1_hello
	li $v0, 4
	syscall

	jal do_task_switch

	j task1

task2:
	la $a0, task2_hello
	li $v0, 4
	syscall

	jal do_task_switch

	j task2

ktask0:
	add  $t0, $0, $0
	jal  do_task_switch
	addi $t1, $0, 10
	la   $s0, str0
	jal do_task_switch
beg0:
	lb   $t2, ($s0)
	beq  $t2, $0, quit0
	sub  $t2, $t2, '0'
	mult $t0, $t1
	mflo $t0
	add  $t0, $t0, $t2
	jal do_task_switch
	add  $s0, $s0, 1
	b    beg0
quit0:
	jal do_task_switch
	add  $v1, $0, $t0
	add  $s0, $0, $v1
	add  $a1, $0, $s0
	jal do_task_switch
	add  $t5, $0, $a1
	add  $t6, $0, $t5
	addi $s0, $0, 1
	add  $v0, $0, $s0
	add  $a0, $0, $t6
	jal do_task_switch
	syscall
	j ktask0


#------------ task1 ---------------

ktask1:
	add  $t0, $0, $0
	addi $t1, $0, 10
	la   $s0, str1
beg1:
	lb   $t2, ($s0)
	beq  $t2, $0, quit1
	jal do_task_switch
	sub  $t2, $t2, '0'
	mult $t0, $t1
	addi $t8, $0, 0
	addi $s5, $t8, 0
	add  $t8, $s5, $s5
	addi $t8, $0, 0
	addi $s5, $t8, 0
	add  $t8, $s5, $s5
	mflo $t0
	add  $t0, $t0, $t2
	add  $s0, $s0, 1
	b    beg1
quit1:
	add  $v1, $0, $t0
	add  $s0, $0, $v1
	jal do_task_switch
	add  $a1, $0, $s0
	add  $t5, $0, $a1
	jal do_task_switch
	add  $t6, $0, $t5
	jal do_task_switch
	addi $s0, $0, 1
	add  $v0, $0, $s0
	jal do_task_switch
	add  $a0, $0, $t6
	jal do_task_switch
	syscall
        j ktask1

do_task_switch:
	addi $sp, $sp, -104 #  26 registers total
	sw $2, 0($sp)
	sw $3, 4($sp)
	sw $4, 8($sp)
	sw $5, 12($sp)
	sw $6, 16($sp)
	sw $7, 20($sp)
	sw $8, 24($sp)
	sw $9, 28($sp)
	sw $10, 32($sp)
	sw $11, 36($sp)
	sw $12, 40($sp)
	sw $13, 44($sp)
	sw $14, 48($sp)
	sw $15, 52($sp)
	sw $16, 56($sp)
	sw $17, 60($sp)
	sw $18, 64($sp)
	sw $19, 68($sp)
	sw $20, 72($sp)
	sw $21, 76($sp)
	sw $22, 80($sp)
	sw $23, 84($sp)
	sw $24, 88($sp)
	sw $30, 92($sp)
	sw $26, 96($sp)
	sw $27, 100($sp)

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal task_switch
