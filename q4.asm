.data 
A: .word 4 6 12 17 23 29 41 45 46 51 120 123
LEN: .word 12

.text
.globl main 

# int binary_search(v, l, r, e) {
#     if (l < r) {
#         m = l + (r - l) / 2;

#         if (v[m] == e) return m;
#         else if (v[m] < e) l = m + 1;
#         else r = m;

#         return binary_search(v, l, r, e);
#     }
#     return -1;
# }

binary_search: # a0 = array, a1 = left, a2 = right, a3 = element to search
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    bge $a1, $a2, bs_return_failure

    sub $t0, $a2, $a1 # (r - l)
    srl $t0, $t0, 1 # (r - l) / 2
    add $t0, $a1, $t0 # l + (r - l) / 2
    
    sll $t1, $t0, 2 # (l + (r - l) / 2) * 4
    add $t1, $a0, $t1 # &v[m]
    lw $t2, 0($t1) # v[m]

    bne $t2, $a3, check_higher
    move $v0, $t0 # return value = m
    j binary_search_epilogue

check_higher:
    bge $t2, $a3, bs_converge_left
    addi $a1, $t0, 1 # l = m + 1
    jal binary_search
    j binary_search_epilogue
bs_converge_left:
    move $a2, $t0 # r = m
    jal binary_search
    j binary_search_epilogue
bs_return_failure:
    li $v0, -1

binary_search_epilogue:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

main:
    la $s0, A 
    la $s1, LEN 
    lw $s1, 0($s1)

    move $a0, $s0
    li $a1, 0
    addi $a2, $s1, 0
    # A: 4 6 12 17 23 29 41 45 46 51 120 123
    li $a3, 20

    jal binary_search

    move $a0, $v0
    li $v0, 1 
    syscall

    li $a0, 10
    li $v0, 11
    syscall 

    li $v0, 10
    syscall