ORG		8000H
IEN0	EQU		0A8H
	MOV		IEN0,	#84Hh	;разрешение прерывания INT1
	MOV		DPTR,	#7FFFh
	MOV		A,		#01h
	MOVX	@DPTR	A		;ввод символа слева,
	;декодированный режим
	LJMP	M2
ORG 8013h					;обработчик прерывания INT1
	MOV		DPTR,	#7FFFh
	MOV		A,		#40h
	MOVX	@DPTR,	A		;разрешение чтения FIFO
	;клавиатуры
	MOV		DPTR,	#7FFEh
	MOVX	A,		@DPTR	;чтение скан-кода
	CJNE	A,		#D9h,	K1
							;проверка скан-кода
							;клавиши «0»
	MOV		DPTR,	#7FFEh
	MOV		A,		#F3h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «0»
	LJMP	EXIT
K1: CJNE	A,		#C0h,	K2
							;проверка скан-кода
							;клавиши «1»
	MOV		DPTR,	#7FFEh
	MOV		A,		#60h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «1»
	LJMP	EXIT
K2: CJNE	A,		#C1h,	K3
							;проверка скан-кода
							;клавиши «2»
	MOV		DPTR,	#7FFEh
	MOV		A,		#B5h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «2»
	LJMP	EXIT
K3: CJNE	A,		#C2h,	K4
							;проверка скан-кода
							;клавиши «3»
	MOV		DPTR,	#7FFEh
	MOV		A,		#F4h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «3»
	LJMP	EXIT
K4: CJNE	A,		#C8h,	K5
							; проверка скан-кода
							;клавиши «4»
	MOV		DPTR,	#7FFEh
	MOV		A,		#66h
	MOVX	@DPTR,	A 		;вывод в видеопамять кода
							;символа «4»
	LJMP	EXIT
K5 CJNE		A, 		#C9h,	K6
							;проверка скан-кода
							;клавиши «5»
	MOV		DPTR,	#7FFEh
	MOV		A,		#D6h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «5»
	LJMP	EXIT
K6: CJNE	A,		#CAh,	K7
							;проверка скан-кода
							;клавиши «6»
	MOV		DPTR,	#7FFEh
	MOV		A,		#D7h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «6»
	LJMP	EXIT
K7: CJNE	A, 		#D0h,	K8
							;проверка скан-кода
							;клавиши «7»
	MOV		DPTR,	#7FFEh
	MOV		A,		#70h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «7»
	LJMP	EXIT
K8: CJNE	A,		#D1h,	K9
							;проверка скан-кода
							;клавиши «8»
	MOV		DPTR,	#7FFEh
	MOV		A,		#F7h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «8»
	LJMP	EXIT
K9: CJNE	A,		#D2h,	K10
							;проверка скан-кода
							;клавиши «9»
	MOV		DPTR,	#7FFEh
	MOV		A,		#F6h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «9»
	LJMP	EXIT
K10: СJNE	A,		#C3h,	K11
							;проверка скан-кода
							;клавиши «A»
	MOV		DPTR,	#7FFEh
	MOV		A,		#77h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «A»
	LJMP	EXIT
K11: CJNE	A,		#CBh,	K12
							;проверка скан-кода
							;клавиши «B»
	MOV		DPTR,	#7FFEh
	MOV		A,		#C7h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «B»
	LJMP	EXIT
K12: CJNE	A,		#D3h,	K13
							;проверка скан-кода
							;клавиши «C»
	MOV		DPTR,	#7FFEh
	MOV		A,		#93h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «C»
	LJMP	EXIT
K13: CJNE	A,		#DBh,	K14
							;проверка скан-кода
							;клавиши «D»
	MOV		DPTR,	#7FFEh
	MOV		A,		#E5h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «D»
	LJMP	EXIT
K14: CJNE	A,		#D8h,	K15
							;проверка скан-кода
							;клавиши «*»
	MOV		DPTR,	#7FFEh
	MOV		A,		#97h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «E»
	LJMP	EXIT
K15: CJNE	A,		#DAh,	EXIT
							;проверка скан-кода
							;клавиши «#»
	MOV		DPTR,	#7FFEh
	MOV		A,		#17h
	MOVX	@DPTR,	A		;вывод в видеопамять кода
							;символа «F»
EXIT:
	RETI					;выход из обработчика
							;прерывания INT1
M2:
	MOV		DPTR,	#7FFFh
	MOV		A,		#90h
	МOVX	@DPTR,	A		;разрешение записи в видеопамять
							;с автоинкрементированием адреса
	LJMP	$

	END