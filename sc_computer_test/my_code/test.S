# |    | used |   |
# | 24 |  6   | 2 |
# addr[7]: 0 -> mem
#          1 -> device
#              0 -> output
#              1 -> input
# addr             back 2 type
# 00000: hex0     65408
# 00001: hex1     65412
# 00010: hex2     65416
# 00011: hex3     65420
# 00100: hex4     65424
# 00101: hex5     65428
# 10000: sw0~9      65472

start:
# $0 is 0
    xor $0, $0, $0
    j main_loop
main_loop:  
# load 2 number to r1, r2
    lw $1, 65472($0)
    sra $2, $1, 5
    andi $1, $1, 31
# calculate sum
    add $3, $1, $2
# to hex
    andi $4, $1, 15
    sra $1, $1, 4
    andi $5, $2, 15
    sra $2, $2, 4
    andi $6, $3, 15
    sra $3, $3, 4
# show the result
    sw $4, 65408($0)
    sw $1, 65412($0)
    sw $5, 65416($0)
    sw $2, 65420($0)
    sw $6, 65424($0)
    sw $3, 65428($0)
    j main_loop
