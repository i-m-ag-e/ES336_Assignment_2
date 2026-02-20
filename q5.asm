.data
A: .word 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
B: .word 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
C: .space 100 # (5 * 5 * 4)
N: .word 5

# void matrix_multiply(a, b, n, c) {
#     for (int i  = 0; i < N; ++i) {
#         for (int j = 0; j < N; ++j) {
#             for (int k = 0; k < N; ++k) {
#                 C[i][j] += A[i][k] * B[k][j];
#             }
#         }
#     }
# }

.text 
.globl main

matrix_multiply: # a0 = A, a1 = B, a2 = N, a3 = C
    li $t0, 0
    li $t1, 0
    li $t2, 0

    matrix_mul_loop_i:
        beq $t0, $a2, matrix_mul_loop_i_end
        li $t1, 0

        matrix_mul_loop_j:
            beq $t1, $a2, matrix_mul_loop_j_end
            li $t2, 0
            
            matrix_mul_loop_k:
                beq $t2, $a2, matrix_mul_loop_k_end

                mult $t0, $a2 
                mflo $t5 # (i * N)
                mult $t2, $a2
                mflo $t4 # (k * N)

                add $t3, $t5, $t2 # (i * N) + k
                sll $t3, $t3, 2
                add $t3, $a0, $t3 # a0 + ((i * N) + k) * 4 = &A[i][k]
                lw $t3, 0($t3)

                add $t4, $t4, $t1 # (k * N) + j
                sll $t4, $t4, 2
                add $t4, $a1, $t4 # a1 + ((k * N) + j) * 4 = &B[k][j]
                lw $t4, 0($t4)

                mult $t3, $t4 
                mflo $t3 # A[i][k] * B[k][j]

                add $t5, $t5, $t1  # (i * N) + j
                sll $t5, $t5, 2
                add $t5, $a3, $t5 # &C[i][j]
                lw $t4, 0($t5)
                add $t4, $t4, $t3 # C[i][j] += A[i][k] * B[k][j]
                sw $t4, 0($t5) 

                addi $t2, $t2, 1 # k++
                j matrix_mul_loop_k

            matrix_mul_loop_k_end:
            
            addi $t1, $t1, 1
            j matrix_mul_loop_j

        matrix_mul_loop_j_end:

        addi $t0, $t0, 1
        j matrix_mul_loop_i

    matrix_mul_loop_i_end:
        jr $ra


main:
    la $a0, A 
    la $a1, B 
    la $a3, C 
    la $a2, N 
    lw $a2, 0($a2)

    jal matrix_multiply

    # uncomment to print the final matrix 

    # la $s0, C 
    # move $s1, $a2
    # li $t0, 0
    # move $t1, $s1 
    # mult $t1, $t1 
    # mflo $t1 
    # sll $t1, $t1, 2
    
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
