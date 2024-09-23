ORG	0000h	;ORG	8000h
	JMP		START
ORG	000Bh
	JMP		TIMER
P4	EQU		0C0h
	
START:
	MOV		P4,		#002h
LOOP:
	MOV		DPTR,	#7FFBh		;01
	MOVX	A,		@DPTR
	JNB		ACC.0,	LOOP
	
	MOV		DPTR,	#7FFAh		;0 0 0 0 X3 X2 X1 X0
	MOVX	A,		@DPTR
	MOV		B,		A
GET_MASK:	
	MOV 	C, 		ACC.3
	CLR		ACC.3 
	MOV		R0,		A
	INC		R0
	JC		HIGH_BITE_MASK
LOW_BITE_MASK:
	MOV		DPTR,	#801Eh		;00
	MOVX	A,	@DPTR
	JMP		DEC_CHECK_MASK
HIGH_BITE_MASK:
	MOV		DPTR,	#801Fh		;FF
	MOVX	A,		@DPTR
	JMP		DEC_CHECK_MASK
SHIFT_RIGHT_MASK:
	RR		A
DEC_CHECK_MASK:
	DJNZ	R0,		SHIFT_RIGHT_MASK
	MOV		C,		ACC.0
	MOV		AC,		C
	MOV		A,		B
C2_CHECK:
	MOV		C,		ACC.3
	JC		C3_CHECK
	
	MOV		C,		ACC.0		;1
	ANL		C,		/ACC.1
	ANL		C,		/ACC.2
	JC		C2
	
	MOV		C,		ACC.1		;6
	ANL		C,		/ACC.0
	ANL		C,		ACC.2
	JC		C2
C3_CHECK:
	MOV		C,		ACC.2
	JC		C4_CHECK
	
	MOV		C,		ACC.0		;3
	ANL		C,		ACC.1
	ANL		C,		/ACC.3
	JC		C3
	
	MOV		C,		ACC.3		;8
	ANL		C,		/ACC.1
	ANL		C,		/ACC.0
	JC		C3
C4_CHECK:
	MOV		C,		ACC.0
	ANL		C,		ACC.3
	JNC		C5_CHECK
	
	MOV		C,		ACC.1		;15
	ANL		C,		ACC.2
	JC		C4
	
	MOV		C,		ACC.1		;9
	CPL		C
	ANL		C,		/ACC.2
	JC		C4
C5_CHECK:
	MOV		C,		ACC.0
	ANL		C,		/ACC.1
	ANL		C,		ACC.2
	ANL		C,		ACC.3
	JC		C5
	JB		AC,		C1
C0_5:
	MOV		R1,		#019h
	JMP		SET_TIMER
C1:
	MOV		R1,		#032h
	JMP		SET_TIMER
C2:
	JNB		AC,		C1
	MOV		R1,		#064h
	JMP		SET_TIMER
C3:
	JNB		AC,		C1
	MOV		R1,		#096h
	JMP		SET_TIMER
C4:
	JNB		AC,		C1
	MOV		R1, 	#0C8h
	JMP		SET_TIMER
C5:
	JNB		AC,		C1
	MOV		R1,		#0FAh
SET_TIMER:
	MOV		TMOD,	#001H
	MOV		TH0,	#03Ch
	MOV		TL0,	#0B7h		;#0AFh
	SETB	TR0
RESULT:
	MOV 	P4.0,	C	
	MOV 	C, 		ACC.3
	CLR		ACC.3 
	MOV		R0,		A
	INC		R0
	JC		HIGH_BITE_RESULT
LOW_BITE_RESULT:
	MOV		DPTR,	#801Ch		;4A
	MOVX	A,	@DPTR
	JMP		DEC_CHECK_RESULT
HIGH_BITE_RESULT:
	MOV		DPTR,	#801Dh		;A3
	MOVX	A,		@DPTR
	JMP		DEC_CHECK_RESULT
SHIFT_RIGHT_RESULT:
	RR		A
DEC_CHECK_RESULT:
	DJNZ	R0,		SHIFT_RIGHT_RESULT
	MOV		C,		ACC.0
	CPL		C
	MOV		P4.1,	C
	JMP		TIMER_CYCLE
TIMER:
	CLR		TF0
	DJNZ	R1,		TIMER_CONTINUE
TIMER_STOP:
	CLR		TR0
	JMP		RESET_READY_BIT
TIMER_CONTINUE:
	MOV		TH0,	#03Ch
	MOV		TL0,	#0B7h		;#0AFh
TIMER_CYCLE:
	JNB		TF0,	TIMER_CYCLE
	JMP		TIMER
RESET_READY_BIT:	
	MOV 	DPTR,	#7FFBh
	CLR		A
;	MOVX	@DPTR,	A			;RESET READY BIT
INCREMENT_X:
	MOV		DPTR,	#7FFAh
	MOVX	A,		@DPTR
	INC		A
	MOVX	@DPTR,		A

	JMP		LOOP
	END