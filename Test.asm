LW $1, 0($0); Load A
LW $2, 64($0); Load B
MULT $3, $1, $2; A x B
LOCK_T0: LL $5, 132($0);
ADD $5, $5, $3;
SC $5, 132($0);
BEQ $5, $0, LOCK_T0;
Barrier_T0: LL $6, 136($0); Barrier
ADDI $6, $6, 1;
SC $6, 136($0);
BEQ $6, $0, Barrier_T0;
ADDI $7, $0, 16; Initialize $7 to 16
LW $6, 136($0); load the barrier 
BNE $7, $6, Sleep_T0;
CACHE 10101, 128($0);
Sleep_T0: J Sleep_T0;