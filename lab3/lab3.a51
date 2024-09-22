ORG	0000h	;ORG	8000h
	LJMP		START
ORG	0003h
	LJMP		INTER
P4	EQU		0C0h
	
START:
	SETB	EX0					; enable INT0
	SETB	EA					; enable global
	SETB	IT0					; 1/0
CYCLE:
	MOV		P4,		R7
	SJMP	CYCLE
	
INTER:
	MOV		DPTR,	#7FFAh
	MOVX	A,		@DPTR

	MOV		DPH, 	#80h
	RR		A
	MOV		B,		A
	ANL		A,		#03h
	ADD		A,		#20h
	MOV		DPL,	A
	MOVX	A,		@DPTR
	MOV		R0,		A
	
	MOV		A,		B
	RR		A
	RR		A
	ANL		A,		#03h
	ADD		A,		#24h
	MOV		DPL,	A
	MOVX	A,		@DPTR
	MOV		R1,		A

	MOV		A,		B
	JB		ACC.7,	OPER_2
OPER_1:
	MOV		R0,		#0FFh
	MOV		R1,		#0FFh
	MOV		R2,		#0FFh
	MOV		R3,		#0FFh
	MOV		R4,		#0FFh
	MOV		R5,		#0FFh
	MOV		R6,		#0FFh
	MOV		R7,		#0FFh
	JMP		INTER_END
OPER_2:
	MOV		R0,		#00h
	MOV		R1,		#00h
	MOV		R2,		#00h
	MOV		R3,		#00h
	MOV		R4,		#00h
	MOV		R5,		#00h
	MOV		R6,		#00h
	MOV		R7,		#00h
INTER_END:
	RETI
	
	END
