ORG 8000h
    LJMP	M1
;******************************************************************************
ORG 8003h					;обработчик прерывания INT0
	MOV 	DPTR,   #7FFAh	;прием кода символа в аккумулятор
	MOVX    A, 		@DPTR
	MOV		R4,		A  		;сохранение кода символа в R4
	SWAP	A
	MOV		0C0h,   A		;выдача кода символа в порт Р4
	MOV		DPTR,   #7FFBh	;передача кода для индикации на шкалах ;C и D
	MOVX	@DPTR,  A
	LCALL	VIVOD			;вызов подпрограммы вывода на ЖКИ
							;символа в первое знакоместо первой
							;строки, код символа в R4
    RETI
;******************************************************************************
M1:
	MOV		A,		#01h	;настройка прерываний
							;INT0 – по фронту
	MOV		TCON,	A
	MOV		A,		#81h	;разрешение прерывания от INT0
	MOV		IE,		A
	LJMP	$
;******************************************************************************
							;подпрограмма вывода на ЖКИ символа в
							;первое знакоместо первой строки
							;код символа в R4
VIVOD:
	MOV		A,		#38H	;две строки размер символа 5*8 точек
	LCALL	DINIT			;вызов подпрограммы записи команды в
							;управляющий регистр дисплея
	MOV		A,		#0CH	;включение дисплея
	LCALL	DINIT
	MOV		A,		#06H	;сдвиг курсора вправо после вывода
							;символа
	LCALL	DINIT
	MOV		A,		#02H
	LCALL	DINIT
	MOV		A,		#01H	;очистка дисплея
	LCALL	DINIT
	MOV		A,		R4		;код символа из R4 в аккумулятор
	LCALL	DISP			;вызов подпрограммы записи кода
							;символа в регистр данных дисплея
	RET
;******************************************************************************
							;подпрограмма записи команды
							;в управляющий регистр дисплея
DINIT:
	MOV		R0,		A
	MOV		DPTR,	#7FF6H	;ожидание установки флага завершения
							;записи в память дисплея
BF:
	MOVX	A,		@DPTR
	ANL		A,		#80H
	JNZ		BF
	MOV		DPTR,	#7FF4H	;запись кода команды в управляющий
							;регистр дисплея
	MOV		A,		R0
	MOVX	@DPTR,	A
	RET
;******************************************************************************
							;подпрограмма записи кода символа
							;в регистр данных дисплея
DISP:
	MOV		R0,		A
	MOV		DPTR,	#7FF6H	;ожидание установки флага завершения
							;записи в память дисплея
BF1:
	MOVX	A,		@DPTR
	ANL		A,		#80H
	JNZ		BF1
	MOV		DPTR,	#7FF5H	;запись значения кода символа в регистр
							;данных дисплея
	MOV		A,		R0
	MOVX	@DPTR,	A
	RET
;******************************************************************************
	END