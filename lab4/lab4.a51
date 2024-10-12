ORG	0000h
;ORG	8000h
	LJMP		START
ORG	0013h
;ORG	8013h
	LJMP		INTERRUPTION
P4	EQU		0C0h
	
START:
	MOV		SP,		#30h		;very important!

	LCALL	INIT_LCD
	LCALL	RESET_SSI

	SETB	EX1					; enable INT1
	SETB	EA					; enable global
	SETB	IT1					; 1/0

	MOV		DPTR,	#7FFFh		;
	MOV		A,		#01h		;FIFO wright enable
	MOVX	@DPTR,	A			;decoding mode
	
CYCLE_INF:
	MOV		P4,		R7
	SJMP	CYCLE_INF

;*******************************************************************************
;interruption function
;flag 	F0 = 1 means waiting for 2nd letter (1st letter was 9 or 7)
;		F0 = 0 means waiting for 1st letter
;flag	PSW.1 = 1 means 1st letter was 7 (waiting for B) operation 2
;		PSW.1 = 0 means 1st letter was 9 (waiting for 3) operation 1
;*******************************************************************************
INTERRUPTION:
	MOV		DPTR,	#7FFFh		;
	MOV		A,		#40h		;
	MOVX	@DPTR,	A			;KB FIFO read enable

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

	LCALL	EXTRACT

	JB		PSW.1,	OPER_2
OPER_1:
	LCALL	OPERATION_1
	JMP		PREPARE_RESULT
OPER_2:
	LCALL	OPERATION_2
PREPARE_RESULT:
	MOV		R6,		A
	SWAP	A
	MOV		R7,		A			;R7 - buffer for P4

	MOV		A,		R6			;R0 - buffer for LCD
	ANL		A,		#00Fh		;
	MOV		R0,		A			;4L LCD

	MOV		A,		R7			;R1 - buffer for SSI
	ANL		A,		#00Fh		;
	MOV		R1,		A			;4H SSI

	LCALL	LCD_OUTPUT
	LCALL	SSI_OUTPUT
RET_INT:
;	MOV		DPTR,	#7FFFh		;FIFO wright enable
;	MOV		A,		#01h		;decoding mode
;	MOVX	@DPTR,	A			;

	RETI

;*******************************************************************************
;function to extract operands from memory
;reads 7FFAh
;output to	R0 is value of A[R2]
;			R1 is value of B[R3]
;			R2 is index of A in array A
;			R3 is index of B in array B
;does not require any input			
;*******************************************************************************
EXTRACT:
	MOV		DPTR,	#7FFAh		;get input from tumblers
	MOVX	A,		@DPTR		;
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
	
	RET

;*******************************************************************************
;function for operation 1
;input	R0 is value of A[R2]
;		R1 is value of B[R3]
;		R2 is index of A in array A
;		R3 is index of B in array B
;output	A = sigma_i(num_of_zero_in_group_i * num_of_group_from_left_i) for R1
;*******************************************************************************
OPERATION_1:
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

	RET

;*******************************************************************************
;function for operation 2
;input	R0 is value of A[R2]
;		R1 is value of B[R3]
;		R2 is index of A in array A
;		R3 is index of B in array B
;output	A = (R0 shift left R2 times) shift right R3 times
;*******************************************************************************
OPERATION_2:
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
	RET
RIGHT_CYCLE:
	RR		A
	DJNZ	R3,		RIGHT_CYCLE

	RET

;*******************************************************************************
;function to pass command to LCD
;B is expected to be command
;*******************************************************************************
LCD_CMD:
	MOV		DPTR,	#7FF6H
BF_CMD:							;waiting for ready not-bit 1000.0000
	MOVX	A,		@DPTR		;
	ANL		A,		#80H		;
	JNZ		BF_CMD				;

	MOV		DPTR,	#7FF4H		;send cmd
	MOV		A,		B			;
	MOVX	@DPTR,	A			;

	RET

;*******************************************************************************
;function to pass data to LCD
;B is expected to be value to print
;*******************************************************************************
LCD_DATA:
	MOV		DPTR,	#7FF6H
BF_DATA:						;waiting for ready not-bit 1000.0000
	MOVX	A,		@DPTR		;
	ANL		A,		#80H		;
	JNZ		BF_DATA				;

	MOV		DPTR,	#7FF5H		;wright into V-memory
	MOV		A,		B			;
	MOVX	@DPTR,	A			;

	RET

;******************************************************************************
;init function
;prints surname and task num from memory
;no input required
;*******************************************************************************
INIT_LCD:
	LCALL	RESET_LCD

	MOV		B,		#80h		;move caret to zero
	LCALL	LCD_CMD				;allow wright to V-memory
	
	MOV		DPTR,	#8000h		;surname ptr
	MOV		R0,		#00H		;letter index
	CLR		C
	JMP		INIT_CYCLE
INIT_CONT:
	JC		INIT_END
	SETB	C
	INC		R0
	MOV		B,		#0AFh		;move caret to 2nd line
	LCALL	LCD_CMD				;7th place
	MOV		DPL,	R0
	MOV		DPH,	#80h
INIT_CYCLE:
	MOVX	A,		@DPTR
	JZ		INIT_CONT			;if \0
	MOV		B,		A
	LCALL	LCD_DATA
	MOV		DPH,	#80h		;
	INC		R0					;next letter ptr
	MOV		DPL,	R0			;
	JMP		INIT_CYCLE
INIT_END:
	RET

;*******************************************************************************
;function to clear LCD 
;no input required
;*******************************************************************************
RESET_LCD:
	MOV		B,		#38h		;8 bits, 2 lines
	LCALL	LCD_CMD				;5x8 dots

	MOV		B,		#0Ch		;turn on display, hide caret
	LCALL	LCD_CMD				;disable blinking of caret

	MOV		B,		#06h		;move caret to the right
	LCALL	LCD_CMD				;

	MOV		B,		#02h		;set V-mem ptr to 0
	LCALL	LCD_CMD				;reset screen shift
	
	MOV		B,		#01h		;clear display
	LCALL	LCD_CMD				;

	RET

;*******************************************************************************
;function to clear SSI
;no input required
;*******************************************************************************
RESET_SSI:
	MOV		DPTR,	#7FFFh		;8 places 8 symbols ssi mode
	MOV		A,		#01h		;
	MOVX	@DPTR,	A			;

	MOV		DPTR,	#7FFFh		;set address = 1 for ssi
	MOV		A,		#80h		;
	MOVX	@DPTR,	A			;addresses:	1|2|3|4

	MOV		DPTR,	#7FFEh		;erase selected indicator
	MOV		A,		#00h		;
	MOVX	@DPTR,	A			;

	MOV		DPTR,	#7FFFh		;set address = 2 for ssi
	MOV		A,		#81h		;
	MOVX	@DPTR,	A			;addresses:	1|2|3|4

	MOV		DPTR,	#7FFEh		;erase selected indicator
	MOV		A,		#00h		;
	MOVX	@DPTR,	A			;

	MOV		DPTR,	#7FFFh		;set address = 3 for ssi
	MOV		A,		#82h		;
	MOVX	@DPTR,	A			;addresses:	1|2|3|4

	MOV		DPTR,	#7FFEh		;erase selected indicator
	MOV		A,		#00h		;
	MOVX	@DPTR,	A			;

	MOV		DPTR,	#7FFFh		;set address = 4 for ssi
	MOV		A,		#83h		;
	MOVX	@DPTR,	A			;addresses:	1|2|3|4

	MOV		DPTR,	#7FFEh		;erase selected indicator
	MOV		A,		#00h		;
	MOVX	@DPTR,	A			;

	RET

;*******************************************************************************
;function to code and print symbol on ssi
;input:	R1 - 4 low bits
;*******************************************************************************
SSI_OUTPUT:
	MOV		DPTR,	#7FFFh		;8 places 8 symbols ssi mode
	MOV		A,		#01h		;
	MOVX	@DPTR,	A			;

	MOV		DPTR,	#7FFFh		;set address = 2 for ssi
	MOV		A,		#81h		;
	MOVX	@DPTR,	A			;addresses:	1|2|3|4	

	MOV		DPTR,	#7FFEh		;prepare ptr where to wright symbol
SSI_0:
	CJNE	R1,		#000h,	SSI_1
	MOV		A,		#0F3h
	JMP		SSI_PRINT
SSI_1:
	CJNE	R1,		#001h,	SSI_2
	MOV		A,		#060h
	JMP		SSI_PRINT
SSI_2:
	CJNE	R1,		#002h,	SSI_3
	MOV		A,		#0B5h
	JMP		SSI_PRINT
SSI_3:
	CJNE	R1,		#003h,	SSI_4
	MOV		A,		#0F4h
	JMP		SSI_PRINT
SSI_4:
	CJNE	R1,		#004h,	SSI_5
	MOV		A,		#066h
	JMP		SSI_PRINT
SSI_5:
	CJNE	R1,		#005h,	SSI_6
	MOV		A,		#0D6h
	JMP		SSI_PRINT
SSI_6:
	CJNE	R1,		#006h,	SSI_7
	MOV		A,		#0D7h
	JMP		SSI_PRINT
SSI_7:
	CJNE	R1,		#007h,	SSI_8
	MOV		A,		#070h
	JMP		SSI_PRINT
SSI_8:
	CJNE	R1,		#008h,	SSI_9
	MOV		A,		#0F7h
	JMP		SSI_PRINT
SSI_9:
	CJNE	R1,		#009h,	SSI_A
	MOV		A,		#0F6h
	JMP		SSI_PRINT
SSI_A:
	CJNE	R1,		#00Ah,	SSI_B
	MOV		A,		#077h
	JMP		SSI_PRINT
SSI_B:
	CJNE	R1,		#00Bh,	SSI_C
	MOV		A,		#0C7h
	JMP		SSI_PRINT
SSI_C:
	CJNE	R1,		#00Ch,	SSI_D
	MOV		A,		#093h
	JMP		SSI_PRINT
SSI_D:
	CJNE	R1,		#00Dh,	SSI_E
	MOV		A,		#0E5h
	JMP		SSI_PRINT
SSI_E:
	CJNE	R1,		#00Eh,	SSI_F
	MOV		A,		#097h
	JMP		SSI_PRINT
SSI_F:
	MOV		A,		#017h
SSI_PRINT:
	MOVX	@DPTR,	A			;print symbol ssi

	RET

;*******************************************************************************
;function to code and print symbol on LCD
;input:	R0 - 4 high bits
;*******************************************************************************
LCD_OUTPUT:
	LCALL	RESET_LCD

	MOV		B,		#0B2h		;move caret to 2nd line
	LCALL	LCD_CMD				;10th place

	MOV		A,		#009h		;determine if result belongs to
	SUBB	A,		R0			;[A,F] or [0,9]
	JNC		LESS_LCD			;
GREATER_LCD:
	MOV		A,		#37h		;for values
	ADD		A,		R0			;[A,F]
	JMP		PRINT_LCD
LESS_LCD:
	MOV		A,		#30h		;for values
	ADD		A,		R0			;[0,9]
PRINT_LCD:
	MOV		B,		A			;print value on lcd
	LCALL	LCD_DATA			;

	RET

	END