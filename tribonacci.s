.align 2

.data
list: .space 400
input: .asciiz "Please enter the value of n: "
newline: .asciiz "\n"


.text
.globl main

main: 
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    li $v0, 4
    la $a0, input
    syscall

    li $v0, 5
    syscall

    move $a0, $v0
    bltz $a0, exit_failure
    beqz $a0, exit_success
    
    #Set help registers
    li $t0, 0
    li $t1, 1
    li $t2, 2
    la $t3, list
    move $s0, $a0

    #Stores list[0], input 1
    sw $t1, 0($t3)
    addi $t0, $t0, 1

    li $t4, 1
    beq $a0, $t4, print_list

    #Stores list[1], input 2
    sw $t1, 4($t3)
    addi $t0, $t0, 1

    addi $t4, $t4, 1
    beq $a0, $t4, print_list

    #Stores list[2], input 3
    sw $t2, 8($t3)
    addi $t0, $t0, 1

    addi $t3, $t3, 12

loop:
    beq $t0, $a0, print_list
    lw $t4, -12($t3)
    lw $t5, -8($t3)
    lw $t6, -4($t3)
    add $t7, $t5, $t4
    add $t7, $t7, $t6
    sw $t7, 0($t3)
    addi $t0, $t0, 1
    addi $t3, $t3, 4
    j loop

print_list:
    li $t0, 0
    la $t3, list

print_loop:
    beq $t0, $s0, exit_success
    lw $a0, 0($t3)
    li $v0, 1
    syscall

    la $a0, newline
    li $v0, 4
    syscall

    addi $t0, $t0, 1
    addi $t3, $t3, 4

    j print_loop

exit_failure:
    sw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra

exit_success:
    sw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    jr $ra