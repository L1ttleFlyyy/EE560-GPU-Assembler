; Test RAW dependency
    SUB     $0, $0, $0          ; hard zero
    ADDI    $1, $0, 3           ; temp register
    SHL     $2, $16, $1         ; warpID * 8
    ADD     $2, $8, $2          ; global thrID
    ADDI    $1, $0, 2
    SHL     $3, $2, $1          ; mem location = thrID * 4
    SW      $2, 0($3)           ; 1 negetaive feedback and 1 positive feedback
    LW      $2, 0($3)           ; 0 negetaive feedback and 1 positive feedback
    ADDI    $2, $2, 256
    SW      $2, 0($3)           ; 0 negetaive feedback and 1 positive feedback
    EXIT
    