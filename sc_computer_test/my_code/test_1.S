start:  xor $0, $0, $0
    j main_loop
main_loop:  lw $1, 65472($0)
    sra $2, $1, 5
    andi $1, $1, 31
    add $3, $1, $2
    andi $4, $1, 15
    sra $1, $1, 4
    andi $5, $2, 15
    sra $2, $2, 4
    andi $6, $3, 15
    sra $3, $3, 4
    sw $4, 65408($0)
    sw $1, 65412($0)
    sw $5, 65416($0)
    sw $2, 65420($0)
    sw $6, 65424($0)
    sw $3, 65428($0)
    j main_loop