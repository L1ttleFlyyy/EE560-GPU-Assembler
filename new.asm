SUB $0, $0, $0; hard zero
ADD $1, $8, $16; global thrID
ADDI $2, $0, 2; shamt
SHL $3, $1, $2; mem location = thrID * 4
SW $1, 0($3); store thrID to corresponding location
EXIT
