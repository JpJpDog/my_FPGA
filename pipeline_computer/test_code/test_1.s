start:  j main_loop
transfer:  xor $3, $3, $3
transfer_loop:   addi $1, $1, -10
    sra $2, $1, 31
    bne $2, $0, transfer_end
    addi $3, $3, 1
    j transfer_loop
transfer_end:   addi $1, $1, 10
    jr $31
main_loop:  lw $1, 65472($0)
    sra $4, $1, 5
    andi $1, $1, 31
    add $5, $1, $4
    jal transfer
    sw $1, 65408($0)
    sw $3, 65412($0)
    addi $1, $4, 0
    jal transfer
    sw $1, 65416($0)
    sw $3, 65420($0)
    addi $1, $5, 0
    jal transfer
    sw $1, 65424($0)
    sw $3, 65428($0)
    j main_loop