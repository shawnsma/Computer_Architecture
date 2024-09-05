.align 2

.data
input: .asciiz "Please enter the value of n: "
newline: .asciiz "\n"

.text
.globl main
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, input
    syscall

    li $v0, 5
    syscall

    move $a0, $v0
    jal recurse
    move $a0, $v0

    li $v0, 1
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

recurse:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)

    beqz $a0, base

    move $s0, $a0
    addi $a0, $a0, -1

    jal recurse

    li $s1, 3
    li $s2, 2
    mul $s1, $s1, $s0
    mul $s2, $v0, $s2
    sub $s3, $s1, $s2
    addi $v0, $s3, 7
    j clean
    

base: 
    li $v0, 2

clean:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra


