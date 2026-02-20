.data
# example A
A: .word 74 -156 -223 -69 47 166 257 -281 252 136 34 179 -45 -10 -121 -277 -186 158 258 74 -132 -199 -247 -246 -271 23 240 -115 100 231 297 73 -8 212 150 -214 -144 59 -129 -164 -300 -221 -51 -165 -296 206 -260 -281 -243 161 -240 -155 -49 257 127 -163 222 -1 108 -92 -271 -195 8 -240 157 -211 57 -184 242 -27 133 22 -13 297 178 261 244 -63 -93 -116 -288 -147 -294 94 28 -210 -152 279 -4 -203 -68 -113 167 54 57 226 179 72 117 102
INT_MAX: .word 0x7FFFFFFF
INT_MIN: .word 0x80000000

.text

.globl main
main:
    la $gp, A

    # s0 = lowest value, s1 = lowest value index
    # s2 = Sum of elements
    # s3 = highest value, s4 = highest value index

    la $t0, INT_MAX 
    lw $s0, 0($t0) # INT_MAX
    li $s1, 0

    la $t0, INT_MIN
    lw $s3, 0($t0) # INT_MIN
    li $s4, 0
    li $s2, 0

    move $t0, $gp # base pointer of A
    # t1 = A[i]

    iter_A:
        sub $t2, $t0, $gp 
        li $t3, 400
        beq $t2, $t3, end_iter_A # if (t0 - gp > 400)
        lw $t1, 0($t0)

        bge $t1, $s0, check_highest 
        
        # $t1 is the lowest value 
        move $s0, $t1 
        sub $s1, $t0, $gp 

        # technically, check_highest can be skipped now, but if all elements in A are same, lowest_value = highest_value
        # so for that case, we need to check for the highest value as well
    check_highest:
        ble $t1, $s3, loop_epi 

        # t1 is the highest 
        move $s3, $t1 
        sub $s4, $t0, $gp 

    loop_epi: 
        add $s2, $s2, $t1 
        addi $t0, $t0, 4 
        j iter_A 

    end_iter_A:
    li $t0, 100
    div $s2, $t0
    mflo $s2 
    
    move $v0, $s3 
    move $v1, $s4

    # s1 and v1 are address offsets from A, need to divide by 4 to get index 
    srl $s1, $s1, 2 
    srl $v1, $v1, 2
    
    li $v0, 10
    syscall