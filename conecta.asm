;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
    LINEA5  DB 	" | | | | | |A|",13,10,"$"  ;Lineas del conecta 4
    LINEA4  DB  " | | | | | |B|",13,10,"$"
    LINEA3  DB  " | | | | | |C|",13,10,"$"
    LINEA2  DB  " | | | | | |D|",13,10,"$"
    LINEA1  DB  " | | | | | |E|",13,10,"$"
    LINEA0  DB  " | | | | | |F|",13,10,"$"
    CLR_PANT    DB  1BH,"[2","J$"   ;Limpiar pantalla
    LINEAS_SIZE DW  6   ;Numero de lineas del conecta 4
    PEDIR1  DB  "Player $"  ;Primera parte de pedir la posicion
    PEDIR2  DB  " turn (Time left to select move: --s): $"  ;Segunda parte de pedir la posicion
    POSICION    DB  ?   ;Posicion escrita por el jugador (TENER EN CUENTA QUE ESTA EN UNA STRING)
    JUGADOR DB  1   ;Jugador 1 = 1 / Jugador 2  = 2
    GANADOR DB 0    ;Gana jugador 1 = 1 / Gana jugador 2 = 2
DATOS ENDS
;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0)
PILA ENDS
;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
	ASSUME CS:CODE,DS:DATOS,SS:PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL (START)
START PROC FAR
;INICIALIZACION DE LOS REGISTROS DE SEGMENTO
	MOV AX,DATOS
	MOV DS,AX	;FIN DE LAS INICIALIZACIONES

L1:                         ;Bucle hasta que se cumplirá hasta que se gane o nos quedemos sin espacios (sin implementar aun)
    CALL limpiar_pantalla
    CALL imprimir_pantalla
    CALL leer_numero
    CMP GANADOR, 0
    ;JE L1
    JMP terminar_programa

    limpiar_pantalla PROC   ;Limpia la pantalla
    PUSH AX DX
    MOV AH, 09H
    MOV DX, OFFSET CLR_PANT
    INT 21H
    POP DX AX
    RET
    limpiar_pantalla ENDP

    imprimir_pantalla PROC  ;Imprime el tablero y pide la posicion
    PUSH AX DX
    ;Imprime el tablero
    MOV AH, 09H
    MOV DX, OFFSET LINEA5
    INT 21H
    MOV DX, OFFSET LINEA4
    INT 21H
    MOV DX, OFFSET LINEA3
    INT 21H
    MOV DX, OFFSET LINEA2
    INT 21H
    MOV DX, OFFSET LINEA1
    INT 21H
    MOV DX, OFFSET LINEA0
    INT 21H
    ;Imprime la parte que pide la posicion
    MOV DX, OFFSET PEDIR1
    INT 21H
    MOV AH, 02H
    MOV DL, JUGADOR
    ADD DL, '0'
    INT 21H
    CALL cambiar_jugador
    MOV AH, 09H
    MOV DX, OFFSET PEDIR2
    INT 21H
    POP DX AX
    RET
    imprimir_pantalla ENDP

    leer_numero PROC    ;Lee la posicion y lo guarda en POSICION[2]
    PUSH AX DX
    MOV AH, 0AH
    MOV DX, OFFSET POSICION
    MOV POSICION[0], 2
    INT 21H
    POP DX AX
    RET
    leer_numero ENDP

    cambiar_jugador PROC
    PUSH AX
    MOV AL, 1
    CMP AL, JUGADOR
    JE jugador2
    MOV JUGADOR, 2
    JMP exit
    jugador2:
        MOV JUGADOR, 1
    exit:
        POP AX
        RET
    cambiar_jugador ENDP
terminar_programa:
    MOV AH,4CH
	INT 21H
START ENDP
;FIN DEL SEGMENTO DE CODIGO
CODE ENDS
;FIN DE PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END START

