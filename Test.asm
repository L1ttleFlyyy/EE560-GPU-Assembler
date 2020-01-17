LW $1, 0($0); Load A
LW.S $2, 0($16); dot S test
MULT $3, $16, $8; A x B
LOCK_T0: ; tag test
LWS $5, 128($0)
ADD.s $16, $8, $16; little s test
SWS.S $5, -16($0) ; negtive imme test
BEQ $5, $0, LOCK_T0


; comment test
Barrier_T0: 
        LWS $6, 136($0); unaligned test
ADDI.S $6, $16, -1 ; negtive imme test
SWS $6, 136($0)
BEQ.S $6, $0, Barrier_T0
ADDI $7, $0, 16; Initialize $7 to 16
LW $6, 136($16); load the barrier 
BGT $7, $16, Sleep_T0;
Sleep_T0: J Sleep_T0;
Sleep_T1: J.S Sleep_T1;
