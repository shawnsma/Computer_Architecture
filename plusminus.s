.align 2

.data
inputName: .asciiz "Please enter player name: "
inputScoring: .asciiz "Please enter score of player's team: "
inputOppo: .asciiz "Please enter score of the opposition's team: "
newline: .asciiz "\n"
space: .asciiz " "
finished: .asciiz "DONE\n"

.text
.globl main

main:
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s7, 20($sp)

    jal readinfo

    move $a0, $v0 #a0 carries start of list
    move $a1, $v1 #a1 carries end of list
    jal sorted

    move $a0, $v0
    jal printing

    lw $s7, 20($sp)
    lw $s3, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 24
    jr $ra

sorted:
    addi $sp, $sp, -28
    sw $ra, 0($sp) 
    sw $s0, 4($sp) 
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp) #first node indicator
    sw $s7, 24($sp)

    li $s4, 0 #Initialize v0 as 0
    li $s1, 1

    move $s0, $a0 #s0 has start of linked list
    move $s7, $a1 #s7 has end of linked list
    move $s3, $s0 #s3 tracks the start of sorted

    sort_loop:
        beq $s1, $0, end_sort #end if we reach last node
        lw $s1, 68($s0) #saves the node the current node is linked to 
        sw $0, 68($s0) #enters NULL

        move $a0, $s3 #if not 0, pass in the start of sorted list
        move $a1, $s0
        beqz $s4, _is0

        jal insert_sorted

        move $s3, $v1 #s3 carries the start of the linked list
        move $s0, $s1

        j sort_loop
    
        _is0:
        li $a0, 0 #If this is first node pass on indicator 0
        move $a1, $s0 #as usual pass the tracker along

        jal insert_sorted

        move $s3, $v1 #s3 carries the start of the linked list
        move $s4, $v0 #now no first node
        move $s0, $s1

        j sort_loop

    end_sort:
        move $v0, $s3
        lw $s7, 24($sp)
        lw $s4, 20($sp)
        lw $s3, 16($sp)
        lw $s2, 12($sp)
        lw $s1, 8($sp)
        lw $s0, 4($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 28
        jr $ra 


insert_sorted:
    addi $sp, $sp, -32
    sw $s2, 0($sp)
    sw $s3, 4($sp)
    sw $s4, 8($sp)
    sw $s5, 12($sp)
    sw $s6, 16($sp)
    sw $s7, 20($sp)
    sw $s0, 24($sp)
    sw $s1, 28($sp) #One more copy such that the start is not changing

    move $s2, $a0 #indicator/start of sorted list
    move $s1, $s2 #this is the leading tracker
    move $s3, $a1 #s3 is the node we are on
    beqz $s2, leading_node

    lw $s4, 64($s2) #score of the current node of the sorted list
    lw $s5, 64($s3) #score of the player we are interested

    bgt $s5, $s4, is_new_head
    beq $s5, $s4, addicheck

    move $t3, $s2 #this is the trailing tracker that I keep forgetting

    lw $s1, 68($s2) #if this is not going to be the first node of sorted
    #we move the current node up such that we can start comparing to the next one

    lw $s4, 64($s2) #as well as update the score

    find_position:
        beqz $s1, insert_end 
        lw $s4, 64($s1) #update score of the current node of the sorted list
        bgt $s5, $s4, insert_here
        beq $s5, $s4, addicheck

        lw $t3, 68($t3)
        lw $s1, 68($s1)
        j find_position

    addicheck:
        move $s6, $s1
        move $s7, $s3

        addi_loop:
            lb $t8, 0($s6)
            lb $t9, 0($s7)

            bne $t8, $t9, _done
            beqz $t8, _done
            beqz $t9, _done
            addi $s6, $s6, 1
            addi $s7, $s7, 1
            j addi_loop
            

        _done:
            li $t7, 0
            sub $t7, $t9, $t8
            bltz $t7, options
            lw $t3, 68($t3)
            lw $s1, 68($s1)
            j find_position
        
        options:
            beq $s1, $s2, is_new_head
            j insert_here


    is_new_head:
        sw $s2, 68($s3)
        move $v1, $s3  #this is the new head of the linked list
        j insert_done

    insert_here:
        sw $s3, 68($t3)
        sw $s1, 68($s3)
        move $v1, $s2
        j insert_done

    insert_end:
        sw $s3, 68($t3)
        sw $0, 68($s3)
        move $v1, $s2
        j insert_done

    leading_node:
        move $v1, $s3 #$v1 carries the start of the sorted list
        li $v0, 1 #no longer a first node
        j insert_done

    insert_done:
        lw $s1, 28($sp)
        lw $s0, 24($sp)
        lw $s7, 20($sp)
        lw $s6, 16($sp)
        lw $s5, 12($sp)
        lw $s4, 8($sp)
        lw $s3, 4($sp)
        lw $s2, 0($sp)
        addi $sp, $sp, 32
        jr $ra 

printing:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s1, 4($sp)

    move $s1, $a0

    print_loop:
        beq $s1, $0, end_print

        li $v0, 4
        addi $a0, $s1, 0
        syscall

        li $v0, 4
        la $a0, space
        syscall

        lw $a0, 64($s1)
        li $v0, 1
        syscall

        li $v0, 4
        la $a0, newline
        syscall

        lw $s1, 68($s1)
        j print_loop

    end_print:
        lw $s0, 4($sp)
        lw $ra, 0($sp)
        addi $sp, $sp, 8
        jr $ra


readinfo:
    addi $sp, $sp, -20 
    sw $ra, 0($sp) 
    sw $s0, 4($sp) 
    sw $s1, 8($sp) 
    sw $s2, 12($sp)
    sw $s7, 16($sp)
    li $s0, 0
    li $s7, 0

    read_loop:
        li $v0, 9
        li $a0, 72
        syscall
        move $s1, $v0 #Buffer

        li $v0, 4
        la $a0, inputName
        syscall

        li $v0, 8
        move $a0, $s1 #Move input into buffer
        li $a1, 64
        syscall


        la $a0, 0($s1)
        la $a1, finished
        jal strcmp #See if we are done

        bne $v0, $0, cont

        move $s7, $s1
        sw $0, 64($s7)
        sw $0, 68($s7)
        move $v0, $s0 #v0 carries start of list
        move $v1, $s7 #v1 carries end of list at "DONE"
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        lw $s7, 16($sp)
        addi $sp, $sp, 20 
        jr $ra

    cont:
        move $a0, $s1 #Move the name into the argument
        jal remove_newline

        li $v0, 4
        la $a0, inputScoring
        syscall

        li $v0, 5
        syscall
        move $s2, $v0

        li $v0, 4
        la $a0, inputOppo
        syscall

        li $v0, 5
        syscall

        sub $s2, $s2, $v0
        sw $s2, 64($s1)
        
        beqz $s0, first_node
        sw $s1, 68($s7)
        j update_tail
        
    first_node:
        move $s0, $s1
        move $s7, $s1
        j read_loop
    
    update_tail:
        move $s7, $s1
        j read_loop

remove_newline:
        addi $sp, $sp, -24
        sw $ra, 0($sp)
        sw $s0, 4($sp)
        sw $s1, 8($sp)
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp)

        move $s0, $a0   

    search_loop:
        lb $s1, 0($s0)  
        beqz $s1, done     
        li $s2, 0x0A  
        bne $s1, $s2, next_char 

        add $s3, $s0, $0

    shift_loop:
        lb $s4, 1($s3)   
        sb $s4, 0($s3) 
        addi $s3, $s3, 1 
        bnez $s4, shift_loop      

        j search_loop       

    next_char:
        addi $s0, $s0, 1    
        j search_loop 

    done:
        lw $ra, 0($sp)       
        lw $s0, 4($sp)       
        lw $s1, 8($sp) 
        lw $s2, 12($sp)  
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        addi $sp, $sp, 24   
        jr $ra       

strcmp:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    loop:
        lb $t0, 0($a0)
        lb $t1, 0($a1)

        bne $t0, $t1, strings_not_equal

        beqz $t0, strings_equal

        addi $a0, $a0, 1
        addi $a1, $a1, 1

        j loop

    strings_not_equal:
        li $v0, 1 
        lw $s1, 8($sp)
        lw $s0, 4($sp) 
        lw $ra, 0($sp) 
        addi $sp, $sp, 12       
        jr $ra                   

    strings_equal:
        li $v0, 0
        lw $s1, 8($sp)
        lw $s0, 4($sp) 
        lw $ra, 0($sp) 
        addi $sp, $sp, 12             
        jr $ra