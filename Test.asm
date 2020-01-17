LW $1, 0($0); Load A
LW.S $2, 64($0); Load B
MULT $3, $1, $2; A x B
LOCK_T0: LWS $5, 132($0);
ADD.S $5, $5, $3;
SWS.S $5, 132($0);
BEQ $5, $0, LOCK_T0;
Barrier_T0: LWS $6, 136($0); Barrier
ADDI.S $6, $6, -1;
SWS $6, 136($0);
BEQ.S $6, $0, Barrier_T0;
ADDI $7, $0, 16; Initialize $7 to 16
LW $6, 136($0); load the barrier 
BGT $7, $6, Sleep_T0;
Sleep_T0: J Sleep_T0;
Sleep_T1: J.S Sleep_T1;