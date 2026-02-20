.data
A: .word -8 5 -3 7 10 -3 5 2 -6
B: .word 3 8 9 8 -6 8 8 -2 -2 
C: .space 36 # (3 * 3 * 4)
N: .word 3

.text 
.globl main 

add_matrices: # a0 = A, a1 = B, a2 = C
    la $t0, N 
    lw $t0, 0($t0) # t0 = N
    li $t1, 0 # t1 = index * 4

    # t2 = upper bound = N * N * 4
    move $t2, $t0 
    mult $t2, $t2 
    mflo $t2 
    sll $t2, $t2, 2

    add_loop:
        beq $t1, $t2, end_add_loop

        add $t3, $a0, $t1 
        lw $t4, 0($t3)
        add $t3, $a1, $t1 
        lw $t5, 0($t3)

        add $t4, $t4, $t5
        add $t3, $a2, $t1
        sw $t4, 0($t3)
        
        addi $t1, $t1, 4
        j add_loop 
    end_add_loop:
    
    jr $ra 

main:
    la $a0, A 
    la $a1, B 
    la $a2, C 
    jal add_matrices

    # uncomment to print the final matrix 

    # la $s0, C 
    # la $s1, N 
    # lw $s1, 0($s1)
    # li $t0, 0
    # move $t1, $s1 
    # mult $t1, $t1 
    # mflo $t1 
    # sll $t1, $t1, 2
    # 
    # print_loop:
    #     beq $t0, $t1, end_print_loop 
    #     add $t2, $s0, $t0 
    #     lw $a0, 0($t2)
    #     li $v0, 1
    #     syscall 

    #     li $a0, 32
    #     li $v0, 11
    #     syscall 

    #     srl $t3, $t0, 2
    #     div $t3, $s1 
    #     mfhi $t3
    #     addi $t4, $s1, -1
    #     bne $t3, $t4, skip_newline 
    #     li $a0, 10 
    #     li $v0, 11 
    #     syscall  

    # skip_newline:
    #     addi $t0, $t0, 4
    #     j print_loop 
    # end_print_loop: 

    li $v0, 10
    syscall