start:  lw $1, 65472($0)
    sw $1, 65424($0)
    addi $1, $1, -1
    sw $1, 65408($0)
    addi $1, $1, -3
    sw $1, 65412($0)
    j start
    xor $0, $0, $0