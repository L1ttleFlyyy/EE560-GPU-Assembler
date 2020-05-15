SUB $0, $0, $0; hard zero
ADDI $1, $0, 3; temp register
SHL $2, $16, $1; warpID * 8
ADD $2, $8, $2; global thrID
ADDI $1, $0, 2
SHL $3, $2, $1; mem location = thrID * 4
SW $2, 0($3); store thrID to corresponding location
EXIT
