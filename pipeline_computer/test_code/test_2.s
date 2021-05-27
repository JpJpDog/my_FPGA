start:  j main_loop
    xor $0, $0, $0
transfer:   xor $3, $3, $3
transfer_loop:  addi $1, $1, -10
    sra $2, $1, 31
    bne $2, $0, transfer_end
    xor $0, $0, $0
    j transfer_loop
    addi $3, $3, 1
transfer_end:   jr $31
    addi $1, $1, 10
main_loop:  lw $1, 65472($0)
    sra $4, $1, 5
    andi $1, $1, 31
    jal transfer
    add $5, $1, $4
    sw $1, 65408($0)
    sw $3, 65412($0)
    jal transfer
    addi $1, $4, 0
    sw $1, 65416($0)
    sw $3, 65420($0)
    jal transfer
    addi $1, $5, 0
    sw $1, 65424($0)
    j main_loop
    sw $3, 65428($0)