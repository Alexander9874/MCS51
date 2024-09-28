ORG	0000h	;ORG	8000h
	LJMP		START
ORG	0013h	;ORG	8013h
	LJMP		INTER
P4	EQU		0C0h
	
START:
	SETB	EX1					; enable INT1
	SETB	EA					; enable global
	SETB	IT1					; 1/0

	LCALL	INIT

	MOV		DPTR,	#7FFFh		;
	MOV		A,		#01h		;FIFO wright enable
	MOVX	@DPTR,	A			;decoding mode
	
	MOV		DPTR,	#7FFFh		;VRAM wright enable
	MOV		A,		#081h		;no autoincrement
	MOVX	@DPTR,	A			;set adress 2 (or 1 IDK)
CYCLE_INF:
	MOV		P4,		R7
	SJMP	CYCLE_INF


INTER:
	MOV		DPTR,	#7FFFh		;
	MOV		A,		#40h		;
	MOVX	@DPTR,	A			;FIFO read enable

	MOV		DPTR,	#7FFEh		;
	MOVX	A,		@DPTR		;FIFO read
KB_PREV:	
	JNB		F0,		CHECK_9
	JNB		PSW.1,	CHECK_3
CHECK_B:
	CJNE	A,		#0CBh,	KB_CLR
	JMP		KB_SCS
CHECK_3:
	CJNE	A,		#0C2h,	KB_CLR
	JMP		KB_SCS
CHECK_9:
	CJNE	A,		#0D2h,	CHECK_7
	SETB	F0
	CLR		PSW.1
	JMP		RET_INT
CHECK_7:
	CJNE	A,		#0D0h,	KB_CLR
	SETB	F0
	SETB	PSW.1
	JMP		RET_INT
KB_CLR:
	CLR		F0
	JMP		RET_INT
KB_SCS:
	CLR		F0
	MOV		DPTR,	#7FFAh
	MOVX	A,		@DPTR
PREP_A:
	MOV		DPH, 	#80h
	RR		A
	MOV		B,		A
	ANL		A,		#03h
	MOV		R3,		A
	ADD		A,		#24h
	MOV		DPL,	A
	MOVX	A,		@DPTR
	MOV		R1,		A
PREP_B:	
	MOV		A,		B
	RR		A
	RR		A
	ANL		A,		#03h
	MOV		R2,		A
	ADD		A,		#20h
	MOV		DPL,	A
	MOVX	A,		@DPTR
	MOV		R0,		A

	JB		PSW.1,	OPER_2
OPER_1:
	MOV		R2,		#000h
	MOV		R3,		#000h
	MOV		R4,		#008h
	MOV		R7,		#000h
	SETB	C
	MOV		A,		R1
CYCLE_OP1:
	JB		ACC.0,	ONE
ZERO:	
	CLR		C
	INC		R3
	JMP		DEC_REG
ONE:
	JC		DEC_REG
	INC		R2
	MOV		A,		R2
	MOV		B,		R3
	MUL		AB
	ADD		A,		R7
	MOV		R7,		A
	MOV		R3,		#000h
	SETB	C
DEC_REG:
	MOV		A,		R1
	RR		A
	MOV		R1,		A
	DJNZ	R4,		CYCLE_OP1
END_CYCLE_OP1:
	INC		R2
	MOV		A,		R2
	MOV		B,		R3
	MUL		AB
	ADD		A,		R7
	JMP		INTER_END
OPER_2:
	MOV		A,		R0
	INC		R2
	INC		R3
LEFT_CHECK:
	DJNZ	R2,		LEFT_CYCLE
	JMP		RIGHT_CHECK
LEFT_CYCLE:
	RL		A
	DJNZ	R2,		LEFT_CYCLE
RIGHT_CHECK:
	DJNZ	R3,		RIGHT_CYCLE
	JMP		INTER_END
RIGHT_CYCLE:
	RR		A
	DJNZ	R3,		RIGHT_CYCLE
INTER_END:
	MOV		R6,		A
	SWAP	A
	MOV		R7,		A			;R7 - buffer for P4

	MOV		A,		R6			;
	ANL		A,		#00Fh		;
	MOV		R0,		A			;4L LCD

	MOV		A,		R6			;
	ANL		A,		#00Fh		;
	SWAP	A					;
	MOV		R1,		A			;4H SSI

	;**************************************************************************
	;part to print values on LCD
	MOV		A,		#009h
	SUBB	A,		R0
	JNC		LESS_LCD
GREATER_LCD:
	MOV		A,		#37h		;for values
	ADD		A,		R0			;[A,F]
	JMP		PRINT_LCD
LESS_LCD:
	MOV		A,		#30h		;for values
	ADD		A,		R0			;[0,9]
PRINT_LCD:
	MOV		DPTR,	#8008h		;adress to keep
	MOVX	@DPTR,	A			;value for LCD

	MOV		B,		#0B1h
	LCALL	LCD_CMD
	MOV		B,		#008h
	LCALL	LCD_DATA

	;**************************************************************************
	;part to print values on SSI
	MOV		DPTR,	#7FFEh
SSI_0:
	CJNE	R1,		#000h,	SSI_1
	MOV		A,		#0F3h
	JMP		SSI_PRINT
SSI_1:
	CJNE	R1,		#000h,	SSI_2
	MOV		A,		#060h
	JMP		SSI_PRINT
SSI_2:
	CJNE	R1,		#000h,	SSI_3
	MOV		A,		#0B5h
	JMP		SSI_PRINT
SSI_3:
	CJNE	R1,		#000h,	SSI_4
	MOV		A,		#0F4h
	JMP		SSI_PRINT
SSI_4:
	CJNE	R1,		#000h,	SSI_5
	MOV		A,		#066h
	JMP		SSI_PRINT
SSI_5:
	CJNE	R1,		#000h,	SSI_6
	MOV		A,		#0D6h
	JMP		SSI_PRINT
SSI_6:
	CJNE	R1,		#000h,	SSI_7
	MOV		A,		#0D7h
	JMP		SSI_PRINT
SSI_7:
	CJNE	R1,		#000h,	SSI_8
	MOV		A,		#070h
	JMP		SSI_PRINT
SSI_8:
	CJNE	R1,		#000h,	SSI_9
	MOV		A,		#0F7h
	JMP		SSI_PRINT
SSI_9:
	CJNE	R1,		#000h,	SSI_A
	MOV		A,		#0F6h
	JMP		SSI_PRINT
SSI_A:
	CJNE	R1,		#000h,	SSI_B
	MOV		A,		#077h
	JMP		SSI_PRINT
SSI_B:
	CJNE	R1,		#000h,	SSI_C
	MOV		A,		#0C7h
	JMP		SSI_PRINT
SSI_C:
	CJNE	R1,		#000h,	SSI_D
	MOV		A,		#093h
	JMP		SSI_PRINT
SSI_D:
	CJNE	R1,		#000h,	SSI_E
	MOV		A,		#0E5h
	JMP		SSI_PRINT
SSI_E:
	CJNE	R1,		#000h,	SSI_F
	MOV		A,		#097h
	JMP		SSI_PRINT
SSI_F:
	MOV		A,		#017h
SSI_PRINT:
	MOVX	@DPTR,	A

RET_INT:
	MOV		DPTR,	#7FFFh
	MOV		A,		#01h
	MOVX	@DPTR,	A		;FIFO wright enable
							;decoding mode
	RETI
	
;******************************************************************************
	;function to pass command to LCD
	;B is expected to be command
LCD_CMD:
	MOV		DPTR,	#7FF6H
BF_CMD:
	MOVX	A,		@DPTR
	ANL		A,		#80H
	JNZ		BF_CMD

	MOV		DPTR,	#7FF4H
	MOV		A,		B
	MOVX	@DPTR,	A
	RET

;******************************************************************************
	;function to pass data to LCD
	;B is expected to be DPL adress
LCD_DATA:
	MOV		DPTR,	#7FF6H
BF_DATA:
	MOVX	A,		@DPTR
	ANL		A,		#80H
	JNZ		BF_DATA

	MOV		DPL,	B
	MOV		DPH,	#80h
	MOVX	A,		@DPTR

	MOV		DPTR,	#7FF5H
	MOVX	@DPTR,	A
	RET

;******************************************************************************
	;init function
	;prints surname and task num from memory
	;no input required
INIT:
	MOV		B,		#38H
	LCALL	LCD_CMD
	MOV		B,		#0CH
	LCALL	LCD_CMD
	MOV		B,		#06H
	LCALL	LCD_CMD
	MOV		B,		#01H
	LCALL	LCD_CMD
NAME_PRINT:
	MOV		R0,		#006h
	MOV		R1,		#000h
	MOV		R2,		#080h
NAME_CYCLE:
	MOV		B,		R2
	LCALL	LCD_CMD
	MOV		B,		R1
	LCALL	LCD_DATA
	INC		R1
	INC		R2
	DJNZ	R0,		NAME_CYCLE

	MOV		R2,		#0AEh
	LCALL	LCD_CMD
	MOV		B,		R1
	LCALL	LCD_DATA

	INC		R1
	INC		R2
	
	MOV		R2,		#0AFh
	LCALL	LCD_CMD
	MOV		B,		R1
	LCALL	LCD_DATA

	RET

	END