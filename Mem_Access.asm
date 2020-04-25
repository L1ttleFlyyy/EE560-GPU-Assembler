// R8 is Thread ID
// R0 is #0


//Code #1

		LW 		R2, R8 (8)				// 1 negetaive feedback and 1 positive feedback
		LW 		R2, R8 (8)				// 0 negetaive feedback and 1 positive feedback since cache hit
		ADDI 	R3, R0, #524288
		ADD 	R3, R3, R8
		MULT 	R4, R3
		LD		R3, R4 (16)				// 8 negetaive feedback and 8 positive feedback
		ADDI	R5, R8, #-3
		BGTZ	R5, TARGET
		ADDI	R6, R0, #8
TARGET:	ADDI	R6, R0, #80
		LD		R2, R6 (0)				// 2 negetaive feedback and 2 positive feedback, data on R2 for thrd 0-3 should be same and for thrd 4-7 should be same
	
	
//Code #2		
		
		SW 		R8, R8 (8)				// 1 negetaive feedback and 1 positive feedback
		SW 		R8, R8 (8)				// 0 negetaive feedback and 1 positive feedback since cache hit
		ADDI 	R3, R0, #524288
		ADD 	R3, R3, R8
		MUL 	R4, R3
		SW		R8, R4 (16)				// 8 negetaive feedback and 8 positive feedback
		ADDI	R5, R8, #-3
		BGTZ	R5, TARGET
		ADDI	R6, R0, #8
TARGET:	ADDI	R6, R0, #80
		SW		R8, R6 (0)				// 2 negetaive feedback and 2 positive feedback, data on R2 for thrd 0-3 should be same and for thrd 4-7 should be same
		
		
//Code #3

		LD 		R2, R8 (8)				// 1 negetaive feedback and 1 positive feedback
		ADDI	R2, R2, #10
		SW		R2, R8 (8)				// 0 negetaive feedback and 1 positive feedback since cache hit
        