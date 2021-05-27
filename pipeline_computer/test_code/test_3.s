start:  xor $10, $10, $10
    xor $11, $11, $11
    addi $10, $10, 65280
    addi $11, $11, 65408
    j main_loop
    xor $1, $1, $1
main_loop:  addi $1, $1, 12345
    sw $1, 0($10)    # forward from e_alul
    addi $2, $1, 1
    xor $0, $0, $0  # wait
    sw $2, 4($10)   # forward from m_alu
    lw $3, 0($10)
    sub $4, $1, $3  # load/use hazard
    bne $4 fail
    xor $0, $0, $0
    lw $4, 4($10)
    xor $0, $0, $0  # wait
    sub $5, $2, $4  # forward from mmo
    bne $5 fail
    xor $1, $1, $1
    j main_loop
    xor $1, $1, $1
fail:   addi $1, $1, 8
    sw $1, 0($11)
    j fail
    xor $1, $1, $1