SUB $0, $0, $0; hard zero
SHL $1, $16, 3; warpID * 8
ADD $2, $8, $1; global thrID
SHL $3, $2, 2; mem location = thrID * 4
SW $3, 0($3); store thrID to corresponding location
EXIT
