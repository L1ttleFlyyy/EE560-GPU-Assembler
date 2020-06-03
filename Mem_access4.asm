    ;Note: This program should be running by only one warp.
    SUB     $0, $0, $0      ; hard zero
    ADDI    $1, $0, 32
    MULT    $2, $1, $8
    LW      $1, 768($2)		;8 negetaive feedback and 8 positive feedback -- cl24 to cl31
    LW      $1, 1024($2)	;8 negetaive feedback and 8 positive feedback -- cl32 to cl39
    LW      $1, 1280($2)	;8 negetaive feedback and 8 positive feedback -- cl40 to cl47
    LW      $1, 1536($2)	;8 negetaive feedback and 8 positive feedback -- cl48 to cl55
    LW      $1, 1792($2)	;8 negetaive feedback and 8 positive feedback -- cl56 to cl63
    LW      $1, 2048($2)	;8 negetaive feedback and 8 positive feedback -- cl64 to cl71
    LW      $1, 2304($2)	;8 negetaive feedback and 8 positive feedback -- cl72 to cl79
    LW      $1, 2560($2)	;8 negetaive feedback and 8 positive feedback -- cl80 to cl87
    LW      $1, 2816($2)	;8 negetaive feedback and 8 positive feedback  --> cache filled up -- cl88 to cl95
    LW      $1, 768($2)		;8 negetaive feedback and 8 positive feedback  --> cache miss  -- cl24 to cl31
    EXIT