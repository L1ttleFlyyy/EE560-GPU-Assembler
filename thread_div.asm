			XOR $0, $0, $0 			; AM = 1111_1111 , clear $0 register
			ADDI $1, $0, 7 			; AM = 1111_1111 , load x
			ADDI $2, $0, 15 		; AM = 1111_1111 , load y
			ADDI $3, $0, 4 			; AM = 1111_1111 , $3=4

			BLT.S $8, $3, Thread0123 ; AM = 1111_1111 , threads 4567 continues

			ADDI $4, $0, 6				; AM = 1111_0000 , $4=6
			BLT.S $8, $4, Thread45	; AM = 1111_0000 , threads 67 continues

			ADDI $3, $0, 6				; AM = 1100_0000 , $3=6
			BEQ.S $8, $3, Thread6		; AM = 1100_0000 , threads 7 continues

			AND $5, $1, $2				; AM = 1000_0000 , thread 7 writes
			J Merge67 					; AM = 1000_0000

Thread6:
			OR $5, $1, $2				; AM = 0100_0000 , thread 6 writes

Merge67:
			NOOP.S 						; Synchronization point
			J Merge4567 				; AM = 1100_0000

Thread45:
			ADDI $3, $0, 4				; AM = 0011_0000 , $3=4
			BEQ.S $8, $3, Thread4		; AM = 0011_0000 , thread 5 continues

			XOR $5, $1, $2				; AM = 0010_0000 , thread 5 writes
			J Merge45 					; AM = 0010_0000

Thread4:
			ADD $5, $0, $1 				; AM = 0001_0000 , thread 4 writes

Merge45:
			NOOP.S 						; Synchronization point

Merge4567:
			NOOP.S 						; Synchronization point
			J Merge01234567 			; AM = 1111_0000

Thread0123:
			ADDI $4, $0, 2				; AM = 0000_1111 , $4=2
			BLT.S $8, $4, Thread01	; AM = 0000_1111 , threads 23 continues

			ADDI $3, $0, 2 			; AM = 0000_1100 , $3=2
			BEQ.S $8, $3, Thread2		; AM = 0000_1100 , thread 3 continues

			ADD $5, $1, $2				; AM = 0000_1000 , thread 3 writes
			J Merge23 					; AM = 0000_1000

Thread2:
			SUB $5, $1, $2				; AM = 0000_0100 , thread 2 writes

Merge23:
			NOOP.S 						; Synchronization point
			J Merge0123 				; AM = 0000_1100

Thread01:
			ADDI $3, $0, 0 			; AM = 0000_0011 , $3=0
			BEQ.S $8, $3, Thread0 	; AM = 0000_0011 , thread 1 continues

			MULT $5, $1, $2 				; AM = 0000_0010 , thread 1 writes
			J Merge01 					; AM = 0000_0010

Thread0:
			ADD $5, $0, $2 				; AM = 0000_0001 , thread 0 writes

Merge01:
			NOOP.S 						; Synchronization point

Merge0123:
			NOOP.S 						; Synchronization point

Merge01234567:
			NOOP.S 						; Synchronization point

			SW $5, 30($0)				; store z
			EXIT
