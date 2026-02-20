.data 
A: .word 12, -5, 0, 7, -5, 12, 42, -19, 3, 3, 8, -1, 15, 0, -19, 21
N: .word 16

.text 
.globl main 

swap: # a0 = a, a1 = b
    lw $t0, 0($a0)
    lw $t1, 0($a1)

    sw $t1, 0($a0)
    sw $t0, 0($a1)
    jr $ra

pivot_index: # a0 = arr, a1 = low, a2 = high, returns the pivot index 
    sub $t0, $a2, $a1 # high - low
    srl $t0, $t0, 1 # (high - low) / 2
    add $t1, $a1, $t0 # mid = low + (high - low) / 2

    sll $t2, $a1, 2
    add $t2, $a0, $t2 # &arr[low]
    sll $t3, $t1, 2
    add $t3, $a0, $t3 # &arr[mid]
    sll $t4, $a2, 2
    add $t4, $a0, $t4 # &arr[high]

    lw $t5, 0($t2)
    lw $t6, 0($t3)
    bge $t5, $t6, low_lt_mid 

    move $t5, $t3 # bigger = &arr[mid]
    move $t6, $t2 # smaller = &arr[low]
    j pivot_find_mid

low_lt_mid:
    move $t5, $t2 # bigger = &arr[low]
    move $t6, $t3 # smaller = &arr[mid]

pivot_find_mid:
    lw $t7, 0($t5)
    lw $t8, 0($t4) 
    bge $t7, $t8, pivot_index_check_small_high # arr[bigger] >= arr[high]

    # (arr[bigger] < arr[high]), return bigger 
    sub $v0, $t5, $a0 
    srl $v0, $v0, 2
    jr $ra 

pivot_index_check_small_high:
    lw $t7, 0($t6)
    bge $t7, $t8, pivot_index_ret_smaller 

    # (arr[smaller] < arr[high]), return high 
    move $v0, $a2 
    jr $ra 

pivot_index_ret_smaller:
    # return smaller
    sub $v0, $t6, $a0 
    srl $v0, $v0, 2
    jr $ra


quick_sort: # a0 = arr, a1 = low, a2 = high 
    blt $a1, $a2, quick_sort_begin
    jr $ra # low >= high, return 

quick_sort_begin:
    addi $sp, $sp, -36
    # s0 - s4 are callee saved
    # ra, a0, a1 and a2 are overwritten by recursive calls
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $a0, 8($sp)
    sw $a1, 4($sp)
    sw $a2, 0($sp)

    jal pivot_index # v0 = pivot_index 
    sll $v0, $v0, 2
    add $v0, $a0, $v0 # v0 = &arr[pivot]

    lw $s0, 0($v0) # s0 = arr[pivot]
    sll $s1, $a1, 2
    add $s1, $a0, $s1 # s1 = &arr[low] (i)
    sll $s2, $a2, 2
    add $s2, $a0, $s2 # s2 = &arr[high] (2)

    move $s3, $s1 # s3 = &arr[low] (fixed)
    move $s4, $s2 # s4 = &arr[high] (fixed)

    # swap(&arr[pivot], &arr[high])
    move $a0, $v0 
    move $a1, $s2 
    jal swap

    quick_sort_loop_begin:
        bge $s1, $s2, quick_sort_loop_end # break when i >= j

        quick_sort_leftmost_larger_loop:
            lw $t0, 0($s1)
            slt $t0, $t0, $s0 # arr[i] < pivot
            slt $t1, $s1, $s4 # i < high
            and $t0, $t0, $t1 
            beq $t0, $0, quick_sort_rightmost_smaller_loop

            addi $s1, $s1, 4 # i++ (i += 4)
            j quick_sort_leftmost_larger_loop
        
        quick_sort_rightmost_smaller_loop:
            lw $t0, 0($s2)
            sge $t0, $t0, $s0
            sgt $t1, $s2, $s3 
            and $t0, $t0, $t1 
            beq $t0, $0, quick_sort_loop_check_swap 

            addi $s2, $s2, -4 # j-- (j -= 4)
            j quick_sort_rightmost_smaller_loop

        quick_sort_loop_check_swap:
            bge $s1, $s2, quick_sort_loopback
            move $a0, $s1 
            move $a1, $s2 
            jal swap 
        quick_sort_loopback:
            j quick_sort_loop_begin
    
    quick_sort_loop_end:
        move $a0, $s4 
        move $a1, $s1
        jal swap # swap(&arr[high], &arr[i])

    lw $a0, 8($sp) # arr
    sub $s0, $s1, $a0 
    srl $s0, $s0, 2 
    
    lw $a1, 4($sp) # low 
    addi $a2, $s0, -1 # i - 1
    jal quick_sort

    lw $a0, 8($sp) # arr
    addi $a1, $s0, 1 # i + 1
    lw $a2, 0($sp)
    jal quick_sort

    lw $ra, 32($sp)
    lw $s0, 28($sp)
    lw $s1, 24($sp)
    lw $s2, 20($sp)
    lw $s3, 16($sp)
    lw $s4, 12($sp)
    # a0 - a2 are caller saved 
    addi $sp, $sp, 36
    jr $ra

print_array: # a0 = array, a1 = len
    move $t0, $a0
    li $t1, 0
    move $t2, $a1

print_loop:
    bge $t1, $t2, print_end

    lw $a0, 0($t0)
    li $v0, 1
    syscall

    li $a0, 32
    li $v0, 11
    syscall

    addi $t0, $t0, 4
    addi $t1, $t1, 1
    j print_loop

print_end:
    li $a0, 10
    li $v0, 11
    syscall

    jr $ra

main:
    la $a0, A 
    li $a1, 0
    la $a2, N 
    lw $a2, 0($a2)
    addi $a2, $a2, -1

    jal quick_sort

    la $a0, A 
    la $a1, N 
    lw $a1, 0($a1)
    jal print_array

    li $v0, 10
    syscall