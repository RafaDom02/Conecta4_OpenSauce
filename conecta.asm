;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
    LINEAS  DB 	" | | | | | | |",13,10  ;16 bytes por fila
            DB  " | | | | | | |",13,10  ;32
            DB  " | | | | | | |",13,10  ;48
            DB  " | | | | | | |",13,10  ;64
            DB  " | | | | | | |",13,10  ;80
            DB  " | | | | | | |",13,10,"$"
    GANADOR DB 0    ;Gana jugador 1 = 1 / Gana jugador 2 = 2
    POSICION_INT    DB 0
    JUGADOR DB  1   ;Jugador 1 = 1 / Jugador 2  = 2
    CLR_PANT    DB  1BH,"[2","J$"   ;Limpiar pantalla
    LINEAS_SIZE DW  6   ;Numero de lineas del conecta 4
    PEDIR1  DB  "Player $"  ;Primera parte de pedir la posicion
    PEDIR2  DB  " turn (Time left to select move: --s): $"  ;Segunda parte de pedir la posicion
    MSG_EMPATE  DB "Draw, no more moves left",13,10,"$"
    MSG_JUG1    DB "Player 1 won",13,10,"$"
    MSG_JUG2    DB "Player 2 won",13,10,"$"
    POSICION    DB  ?   ;Posicion escrita por el jugador (TENER EN CUENTA QUE ESTA EN UNA STRING)
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
    CALL limpiar_pantalla   ;Hace un clear a la pantalla
    CALL imprimir_pantalla  ;Imprime el tablero y la linea que pide la posicion
    CALL leer_numero        ;Lee el numero escrito por el jugador
    CALL colocar_ficha      ;Coloca una ficha en la posición escrita por el jugador
    ;CALL comprobar_fila     ;Comprueba si se ha ganado por fila
    CALL comprobar_columna  ;Comprueba si se ha ganado por columna
    CALL comprobar_diagonal ;Comprobar si se ha ganado por diagonal
    CALL hueco_libre        ;Comprueba si queda algun hueco libre en el tablero
    CALL cambiar_jugador    ;Cambia el jugador tras terminar la ronda
    CMP GANADOR, 0          ;Cambia de valor si hay un ganador o si no hay más huecos
    JE L1
    JMP terminar_programa   ;Si ha terminado el juego liberará los recursos ultilizados

    limpiar_pantalla PROC   ;Limpia la pantalla
    PUSH AX DX
    MOV AH, 09H
    MOV DX, OFFSET CLR_PANT
    INT 21H
    POP DX AX
    RET
    limpiar_pantalla ENDP

    imprimir_pantalla PROC  ;Imprime el tablero y pide la posicion
    PUSH AX DX SI
    ;Imprime el tablero
    MOV AH, 09H
    LEA DX, LINEAS
    INT 21H
    ;Imprime la parte que pide la posicion
    POP SI DX AX
    RET
    imprimir_pantalla ENDP 

    colocar_ficha PROC
    PUSH AX DX CX SI
    MOV CL, POSICION_INT
    SUB CL, 1
    MOV AL, 2
    MUL CL
    MOV CX, 0
    MOV SI, 80
    l2:
        CMP AX, 0
        JE fin_l2
        INC SI
        DEC AX
        JMP l2
    fin_l2:
    CMP CX, LINEAS_SIZE
    JE fincambio
    MOV AL, LINEAS[SI]
    CMP AL, ' '
    JE cambiar_espacio
    SUB SI, 16
    INC CX
    JMP fin_l2

    cambiar_espacio:
        CMP JUGADOR, 1
        JE jug1
        MOV LINEAS[SI], 2
        JMP fincambio
        jug1:
            MOV LINEAS[SI], 1
    fincambio:
    POP SI CX DX AX
    RET
    colocar_ficha ENDP

    leer_numero PROC    ;Lee la posicion y lo guarda en POSICION[2]
    PUSH AX DX
    MOV AH, 09H
    MOV DX, OFFSET PEDIR1
    INT 21H
    MOV AH, 02H
    MOV DL, JUGADOR
    ADD DL, '0'
    INT 21H
    MOV AH, 09H
    MOV DX, OFFSET PEDIR2
    INT 21H
    MOV AH, 0AH
    MOV DX, OFFSET POSICION
    MOV POSICION[0], 2
    INT 21H
    MOV DL, POSICION[2]
    SUB DL, '0'
    MOV POSICION_INT, DL    ;Se guarda bien la posicion en int de DL
    POP DX AX
    RET
    leer_numero ENDP

    cambiar_jugador PROC
    PUSH AX
    CMP JUGADOR, 1
    JE jugador2
    MOV JUGADOR, 1
    JMP exit
    jugador2:
        MOV JUGADOR, 2
    exit:
        POP AX
        RET
    cambiar_jugador ENDP

    comprobar_fila PROC
    PUSH AX CX SI
    MOV CL, POSICION_INT
    SUB CL, 1
    MOV AL, 2
    MUL CL
    MOV SI, AX
    MOV CX, LINEAS_SIZE
    l4:
        CMP LINEAS[SI], ' '
        JNE encontrado
        ADD SI, 16
        DEC CX
        JMP l4
    encontrado:
        MOV SI, CX
        MOV CX, 0
        MOV AX, 0
        buscar_si_ganador:
            CMP SI, 12
            JE fin_fila
            CMP LINEAS[SI], 1
            JE jug1_ficha
            ADD SI, 2
            INC CX
            CMP CX, 4
            JE hay_ganador2
            MOV AX, 0
            JMP buscar_si_ganador
            jug1_ficha:
            ADD SI, 2
            INC AX
            CMP AX, 4
            JE hay_ganador1
            MOV CX, 0
            JMP buscar_si_ganador
    hay_ganador1:
    MOV GANADOR, 1
    CALL limpiar_pantalla
    CALL imprimir_pantalla
    MOV AH, 09H
    MOV DX, OFFSET MSG_JUG1
    INT 21H
    JMP fin_fila
    hay_ganador2:
    MOV GANADOR, 2
    CALL limpiar_pantalla
    CALL imprimir_pantalla
    MOV AH, 09H
    MOV DX, OFFSET MSG_JUG2
    INT 21H
    fin_fila:
    POP SI CX AX
    RET
    comprobar_fila ENDP

    comprobar_columna PROC
    RET
    comprobar_columna ENDP

    comprobar_diagonal PROC
    RET
    comprobar_diagonal ENDP

    hueco_libre PROC
    PUSH AX DX CX SI
    MOV CX, 0
    MOV SI, 0
    MOV AX, 0
    l3:
        CMP AX, 7
        JE siguiente_linea
        CMP LINEAS[SI], ' '
        JE final_hueco
        ADD SI, 2
        INC AX
        JMP l3
        siguiente_linea:
            MOV AX, 0
            ADD SI, 3
            INC CX
            CMP CX, LINEAS_SIZE
            JE no_hueco
            JMP l3

    no_hueco:
        MOV GANADOR, 3
        CALL limpiar_pantalla
        CALL imprimir_pantalla
        MOV AH, 09H
        MOV DX, OFFSET MSG_EMPATE
        INT 21H
    final_hueco:
        POP SI CX DX AX
        RET
    hueco_libre ENDP


terminar_programa:
    MOV AH,4CH
	INT 21H
START ENDP
;FIN DEL SEGMENTO DE CODIGO
CODE ENDS
;FIN DE PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END START

