	ORG		0h


;*******************************************************************************
;Redefine registers from context 1 (current context is 0)
;as Ni and Ni_MAX
;*******************************************************************************
	N1		EQU		08h
	N2		EQU		09h
	N3		EQU		0Ah
	N4		EQU		0Bh

	N1_MAX	EQU		0Ch
	N2_MAX	EQU		0Dh
	N3_MAX	EQU		0Eh
	N4_MAX	EQU		0Fh


;*******************************************************************************
;F0 - blocking flag
;P0 - input
;P1 - output of current state of automata
;P2 low nibble - output of amount of mistakes at state 1
;P2 high nibble - output of amount of mistakes at state 2
;P3 low nibble - output of amount of mistakes at state 3
;P3 high nibble - output of amount of mistakes at state 4
;R0 - blinking pointer (24, 25)
;R7 - current state of automata
;To exit final (blocking or finish) state set bit ACC.7
;*******************************************************************************
START:
	MOV		N1,		#00h
	MOV		N2,		#00h
	MOV		N3,		#00h
	MOV		N4,		#00h

	MOV		N1_MAX,	#04h
	MOV		N2_MAX,	#00h
	MOV		N3_MAX,	#00h
	MOV		N4_MAX,	#00h
	
	CLR		F0

	MOV		SP,		#30h
	MOV		P3,		#00h
	MOV		P2,		#00h
	MOV		R7,		#01h
	MOV		P1,		R7
	
	MOV		A,		P0
	MOV		24h,	A
	MOV		25h,	A
	
	MOV		R0,		#25h
MAIN_LOOP:
	MOV		A,		P0
	MOV		@R0,	A
	MOV		A,		R0
	MOV		R1,		A
	XRL		A,		#01h
	MOV		R0,		A
	MOV		R2,		24h
	MOV		A,		25h
	XRL		A,		R2
	
	JZ		MAIN_LOOP
	LCALL	PROCESSING
	JB		F0,		MAIN_BLOCK
	CJNE	R7,		#05h,		MAIN_LOOP
MAIN_FINISH:
	MOV		P1,		#55h
	MOV		P2,		#04h
	MOV		P3,		#00h
MAIN_FINISH_LOOP:
	MOV		A,		P0			;comment this
	JB		ACC.7,	START		;to correspond task
	SJMP	MAIN_FINISH_LOOP
MAIN_BLOCK:
	MOV		P1,		#0AAh
MAIN_BLOCK_LOOP:
	MOV		A,		P0			;comment this
	JB		ACC.7,	START		;to correspond task
	SJMP	MAIN_BLOCK_LOOP


;*******************************************************************************
;Function for indication
;does not require input
;has no output
;*******************************************************************************
INDICATION:
	MOV		P1,		R7
	MOV		A,		N2
	SWAP	A
	ORL		A,		N1
	MOV		P2,		A
	MOV		A,		N4
	SWAP	A
	ORL		A,		N3
	MOV		P3,		A
	RET


;*******************************************************************************
;Function to precess inputed data
;depends on current state of automata
;does not require input
;has no output
;*******************************************************************************
PROCESSING:
	MOV		A,		@R1
N1_CHECK:
	CJNE	R7,		#01h,		N2_CHECK
	LCALL	N1_FUNCTION
	JMP		PROCESSING_RETURN
N2_CHECK:	
	CJNE	R7,		#02h,		N3_CHECK
	LCALL	N2_FUNCTION
	JMP		PROCESSING_RETURN
N3_CHECK:	
	CJNE	R7,		#03h,		N4_CHECK
	LCALL	N3_FUNCTION
	JMP		PROCESSING_RETURN
N4_CHECK:	
	LCALL	N4_FUNCTION
PROCESSING_RETURN:
	LCALL	INDICATION
	RET


;*******************************************************************************
;Function for state 1
;calculates N2_max as max(mod_3(N1+1),2) that is always 2
;input: A is value from P0
;has no output
;*******************************************************************************
N1_FUNCTION:
	XRL		A,		#02h
	JZ		N1_SUCCESS
N1_MISTAKE:
	INC		N1
	MOV		A,		N1_MAX
	SUBB	A,		N1
	JC		N1_ERROR
	JMP		N1_RETURN
N1_SUCCESS:
	MOV		R7,		#02h
	MOV		N2_MAX,		#02h
N1_RETURN:
	RET
N1_ERROR:
	SETB	F0
	JMP		N1_RETURN


;*******************************************************************************
;Function for state 2
;calculates N3_max as min(2*N1,2*N2,1) can be
;	0 if N1 or N2 is 0
;	1 if N1 and N2 are not 0
;input: A is value from P0
;has no output
;*******************************************************************************
N2_FUNCTION:
	XRL		A,		#02h
	JZ		N2_SUCCESS
N2_MISTAKE:
	INC		N2
	MOV		A,		N2_MAX
	SUBB	A,		N2
	JC		N2_ERROR
	JMP		N2_RETURN
N2_SUCCESS:
	MOV		R7,		#03h
	MOV		A,		N1
	JZ		N2_MARK
	MOV		A,		N2
	JZ		N2_MARK
	MOV		A,		#01h
N2_MARK:
	MOV		N3_MAX,	A
N2_RETURN:
	RET
N2_ERROR:
	SETB	F0
	JMP		N2_RETURN


;*******************************************************************************
;Function for state 3
;calculates N3_max as abs(max(N2,N3)-2*N1),
;	N2 is always 2, N3 can be 0 or 1, so max(N2,N3) is 2
;	for N1 > 0 : result is 2(N1-1)
;	for N1 = 0 : result is 2
;input: A is value from P0
;has no output
;*******************************************************************************
N3_FUNCTION:
	XRL		A,		#07h
	JZ		N3_SUCCESS
N3_MISTAKE:
	INC		N3
	MOV		A,		N3_MAX
	SUBB	A,		N3
	JC		N3_ERROR
	JMP		N3_RETURN
N3_SUCCESS:
	MOV		R7,		#04h
	MOV		A,		N1
	JZ		N3_MARK_0
	DEC		A
	RL		A
	JMP		N3_MARK_1
N3_MARK_0:
	MOV		A,		#02h
N3_MARK_1:
	MOV		N4_MAX,	A
N3_RETURN:
	RET
N3_ERROR:
	SETB	F0
	JMP		N3_RETURN


;*******************************************************************************
;Function for state 4
;input: A is value from P0
;has no output
;*******************************************************************************
N4_FUNCTION:
	XRL		A,		#05h
	JZ		N4_SUCCESS
N4_MISTAKE:
	INC		N4
	MOV		A,		N4_MAX
	SUBB	A,		N4
	JC		N4_ERROR
	JMP		N4_RETURN
N4_SUCCESS:
	MOV		R7,		#05h	
N4_RETURN:
	RET
N4_ERROR:
	SETB	F0
	JMP		N4_RETURN

	END