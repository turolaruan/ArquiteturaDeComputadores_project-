; Projeto de CE4411
; Arquitetura de Computadores
; Simulação de Cafeteira
; Gustavo Garcia Bagio
; RA: 24.122.012-8
; Ruan Pastrelo Turola
; RA: 24.122.050-8

; Mapeamento de Hardware (8051)
RS equ P1.3 ; Reg Select ligado em P1.3
EN equ P1.2 ; Enable ligado em P1.2

; Começa o programa no endereço de memória 00h
org 0000h ;

; Pula para a rotina de começo (inicio do programa)
LJMP START

; Rotina de interrupção serial (para receber o valor a ser pago)
org 023H ; Ponteiro da Interrupção do Canal Serial
MOV A,SBUF ; Escreve o valor recebido no registrador A
MOV B, #0DH ; Carrega o valor 0DH no registrador B
CJNE A, B, escreve ; Se o valor recebido for diferente de 0DH, pula para a rotina escreve

voltar: ; Rotina de retorno
    CLR RI ; Reseta o registrador RI para receber novos valores
    RETI ; Retorna para o programa principal

; Rotina para escrever o valor recebido no registrador R6
escreve:
    SUBB A, #30H ; Subtrai o valor 30H do valor recebido (Valor ASCII para inteiro)
    MOV R6, A ; Move o valor recebido para o registrador R6
    AJMP voltar ; Pula para a rotina de retorno

; Continua o programa no endereço de memória 60h    
org 0060h

; Declaração de variáveis (strings) para serem escritas no display
CAFETERIA:
    DB "CAFETERIA BT"
    DB 00h
CAPPUCCINO:
    DB "1-Cappuccino"
    DB 00h
ESPRESSO:
    DB "2-Espresso"
    DB 00h
RISTRETTO:
    DB "3-Ristretto"
    DB 00h
MOCHA:
    DB "4-Mocha"
    DB 00h
MACHIATTO:
    DB "5-Machiatto"
    DB 00h
SELECIONADOR:
    DB "SELECIONE O"
    DB 00h
CAFE:
    DB "CAFE DESEJADO"
    DB 00h
CONFIRMAR:
    DB "Confirmar (#)"
    DB 00h
ACUCAR:
    DB "Qtde de Acucar"
    DB 00h
PREPARAR:
    DB "Preparando..."
    DB 00h
PRONTO:
    DB "Pronto!"
    DB 00h
APROVEITE:
    DB "Aproveite!"
    DB 00h
CONFIRMAR2:
    DB "Confirmar (*)"
    DB 00h
POUCO_ACUCAR:
    DB "7-Pouco acucar"
    DB 00h
MUITO_ACUCAR:
    DB "9-Muito acucar"
    DB 00h
TOTAL:
    DB "Total a pagar"
    DB 00h
VALOR1:
    DB "R$ 1"
    DB 00h
VALOR2:
    DB "R$ 2"
    DB 00h
VALOR3:
    DB "R$ 3"
    DB 00h
VALOR4:
    DB "R$ 4"
    DB 00h
VALOR5:
    DB "R$ 5"
    DB 00h
VALOR0:
    DB "R$ 0"
    DB 00h
INSIRA:
    DB "Insira o valor"
    DB 00h
ZERO:
    DB "Pagar (0)"
    DB 00h
SALDO:
    DB "Saldo"
    DB 00h
LBLINSUFICIENTE:
    DB "Insuficiente!"
    DB 00h
PGTOCONCLUIDO:
    DB "Pgto. Concluido"
    DB 00h
LBLTROCO:
    DB "Troco "
    DB 00h


; Rotina de início do programa
START:
    ; Coloca os dados na RAM para funcionamento do teclado
    MOV 40H, #'#'
    MOV 41H, #'0'
    MOV 42H, #'*'
    MOV 43H, #'9'
    MOV 44H, #'8'
    MOV 45H, #'7'
    MOV 46H, #'6'
    MOV 47H, #'5'
    MOV 48H, #'4'
    MOV 49H, #'3'
    MOV 4AH, #'2'
    MOV 4BH, #'1'

    MOV SCON, #50H ; porta serial no modo 1 e habilita a recepção
    MOV PCON, #80h ; set o bit SMOD
    MOV TMOD, #20H ; CT1 no modo 2
    MOV TH1, #243 ; valor para a recarga
    MOV TL1, #243 ; valor para a primeira contagem
    MOV IE,#90H ; Habilita interrupção serial
    SETB TR1

; Rotina de exibição do menu principal
main:
    ACALL lcd_init
    JMP EXIBICAO
    EXIBICAO:
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#CAFETERIA
    ACALL escreveStringROM
    ACALL clearDisplay
    CALL delay ; wait for BF to clear

; Rotina de seleção do café (Parte 1)
MENU1:
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#CAPPUCCINO
    ACALL escreveStringROM
    MOV A, #42h
    ACALL posicionaCursor
    MOV DPTR,#ESPRESSO
    ACALL escreveStringROM
    ACALL clearDisplay
    CALL delay

; Rotina de seleção do café (Parte 2)
MENU2:
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#RISTRETTO
    ACALL escreveStringROM
    MOV A, #42h
    ACALL posicionaCursor
    MOV DPTR,#MOCHA
    ACALL escreveStringROM
    ACALL clearDisplay
    CALL delay

; Rotina de seleção do café (Parte 3)
MENU3:
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#MACHIATTO
    ACALL escreveStringROM
    ACALL clearDisplay
    CALL delay

; Rotina de seleção do café (Parte 4)
SELECIONA:
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#SELECIONADOR
    ACALL escreveStringROM
    MOV A, #42h
    ACALL posicionaCursor
    MOV DPTR,#CAFE
    ACALL escreveStringROM
    CALL delay
    JMP ROTINA

; Rotina de leitura do teclado
ROTINA:
    ACALL leituraTeclado
    JNB F0, ROTINA ;if F0 is clear, jump to ROTINA
    CLR F0
    JMP ROTINA
    escreveStringROM:
    MOV R1, #00h
    ; Inicia a escrita da String no Display LCD

; Loop para escrever a String no Display LCD
loop:
    MOV A, R1
    MOVC A,@A+DPTR ; move data from code memory to accumulator
    JZ finish ; if A is 0, then end of data has been reached - jump out of loop
    ACALL sendCharacter ; send data in A to LCD module
    INC R1 ; point to next piece of data
    MOV A, R1
    JMP loop ; repeat

; Rotina de ponte para retorno
finish:
    RET

; Função de leitura do teclado matricial (scan das linhas)
leituraTeclado:
    MOV R0, #0 ; clear R0 - the first key is key0
    ; scan row0
    MOV P0, #0FFh
    CLR P0.0 ; clear row0
    CALL colScan0 ; call column-scan subroutine
    JB F0, finish2 ; | if F0 is set, jump to end of program
    ; scan row1
    SETB P0.0			; set row0
    CLR P0.1			; clear row1
    CALL colScan1		; call column-scan subroutine
    JB F0, finish		; | if F0 is set, jump to end of program; | (because the pressed key was found and its number is in  R0)
    ; scan row2
    SETB P0.1 ; set row1
    CLR P0.2 ; clear row2
    CALL colScan2 ; call column-scan subroutine
    JB F0, finish2 ; | if F0 is set, jump to end of program
    ; scan row3
    SETB P0.2 ; set row2
    CLR P0.3 ; clear row3
    CALL colScan3 ; call column-scan subroutine
    JB F0, finish2 ; | if F0 is set, jump to end of program

; Rotina de retorno 2
finish2:
    RET

; Rotina de seleção da quantidade de açúcar no café
colocaAcucar:
    SETB F0
    ACALL clearDisplay
    MOV A, #01h
    ACALL posicionaCursor
    MOV DPTR,#ACUCAR
    ACALL escreveStringROM
    CALL delay
    ACALL clearDisplay
    MOV A, #01h
    ACALL posicionaCursor
    MOV DPTR,#POUCO_ACUCAR
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#MUITO_ACUCAR
    ACALL escreveStringROM
    RET

; Exibe tela de pouco açúcar
POUCO:
    SETB F0
    ACALL clearDisplay
    MOV A, #01h
    ACALL posicionaCursor
    MOV DPTR,#POUCO_ACUCAR
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR2
    ACALL escreveStringROM
    RET

; Exibe tela de muito açúcar
MUITO:
    SETB F0
    ACALL clearDisplay
    MOV A, #01h
    ACALL posicionaCursor
    MOV DPTR,#MUITO_ACUCAR
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR2
    ACALL escreveStringROM
    RET

; Exibe tela de total a pagar
TOTAL_TELA:
    SETB F0
    ACALL clearDisplay
    MOV A, #01h
    ACALL posicionaCursor
    MOV DPTR,#TOTAL
    ACALL escreveStringROM
    MOV A, #46h
    ACALL posicionaCursor

    ; Condições if else para determinar o valor a ser exibido de acordo com o café selecionado
    if:
        MOV B, R4
        MOV A, #01H
        cjne A, B, elseif1 ; if R4 is not equal to 01H, jump to elseif1
        MOV DPTR,#VALOR1
        LJMP fim_valor

    elseif1:
        MOV A, #02H
        cjne A, B, elseif2 ; if R4 is not equal to 02H, jump to elseif2
        MOV DPTR,#VALOR2
        LJMP fim_valor

    elseif2:
        MOV A, #03H
        cjne A, B, elseif3 ; if R4 is not equal to 03H, jump to elseif3
        MOV DPTR,#VALOR3
        LJMP fim_valor

    elseif3:
        MOV A, #04H
        cjne A, B, elseif4 ; if R4 is not equal to 04H, jump to elseif4
        MOV DPTR,#VALOR4
        LJMP fim_valor

    elseif4:
        MOV A, #05H
        cjne A, B, elseif5 ; if R4 is not equal to 05H, jump to elseif5
        MOV DPTR,#VALOR5
        LJMP fim_valor

    elseif5:
        MOV DPTR, #VALOR0 ; write VALOR0 to DPTR
        LJMP fim_valor

    ; escreve o valor no display
    fim_valor:
        ACALL escreveStringROM
        CALL delay
        CALL delay

    ; escreve a instrução para pagamento
    ACALL clearDisplay
    MOV A, #01h
    ACALL posicionaCursor
    MOV DPTR,#INSIRA
    ACALL escreveStringROM
    MOV A, #43h
    ACALL posicionaCursor
    MOV DPTR,#ZERO
    ACALL escreveStringROM
    RET

; Exibe a tela de preparação do café
PREP:
    SETB F0
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#PREPARAR
    SETB P3.0 ; gira o motor
    CLR P3.1 ; gira o motor
    ACALL escreveStringROM
    call delay_preparing
    SETB P3.0 ; para o motor
    CLR P3.0 ; para o motor
    ACALL clearDisplay
    MOV A, #05h
    ACALL posicionaCursor
    MOV DPTR,#PRONTO
    ACALL escreveStringROM
    MOV A, #43h
    ACALL posicionaCursor
    MOV DPTR,#APROVEITE
    ACALL escreveStringROM
    CALL delay
    CALL delay
    CALL delay
    JMP EXIBICAO ; após café pronto, retorna ao menu principal
    RET

; Rotina de cálculo do troco a ser recebido pelo pagador
pagamento:

    MOV A, R6 ; move o valor recebido para o registrador A
    MOV B, R4 ; move o valor do café selecionado para o registrador B

    cjne A, B, incorreto ; se os valores não forem iguais, pula para incorreto
    MOV R3, #0H ; se os valores forem iguais, exibe troco 0
    LJMP concluido ; pagamento concluído

    ; se os valores forem diferentes, calcula se há troco ou se falta dinheiro
    incorreto:
        JC insuficiente ; se o valor recebido for menor que o valor do café, pula para insuficiente (verifica carry acionada pelo CJNE)

    ; se o valor recebido for maior que o valor do café, calcula o troco
    SUBB A, B ; subtrai o valor do café do valor recebido
    MOV R3, A ; move o valor do troco para o registrador R3
    LJMP concluido ; pagamento concluído

    ; se o valor recebido for menor que o valor do café, exibe tela de saldo insuficiente
    insuficiente:
        ACALL clearDisplay
        MOV A, #05h
        ACALL posicionaCursor
        MOV DPTR,#SALDO
        ACALL escreveStringROM
        MOV A, #41h
        ACALL posicionaCursor
        MOV DPTR,#LBLINSUFICIENTE
        ACALL escreveStringROM
        CALL delay
        LCALL total_tela_jump
        ret

    ; exibe tela de pagamento concluído
    concluido:
        ACALL clearDisplay
        MOV A, #01h
        ACALL posicionaCursor
        MOV DPTR,#PGTOCONCLUIDO
        ACALL escreveStringROM
        MOV A, #42h
        ACALL posicionaCursor
        MOV DPTR,#LBLTROCO
        ACALL escreveStringROM
        MOV A, #48h
        ACALL posicionaCursor

    ; Condições if else para determinar o valor a ser exibido de acordo com o troco
    if_pgto:
        MOV B, R3
        MOV A, #01H
        cjne A, B, elseif1_pgto
        MOV DPTR,#VALOR1
        LJMP fim_valor_pgto

    elseif1_pgto:
        MOV A, #02H
        cjne A, B, elseif2_pgto
        MOV DPTR,#VALOR2
        LJMP fim_valor_pgto

    elseif2_pgto:
        MOV A, #03H
        cjne A, B, elseif3_pgto
        MOV DPTR,#VALOR3
        LJMP fim_valor_pgto

    elseif3_pgto:
        MOV A, #04H
        cjne A, B, elseif4_pgto
        MOV DPTR,#VALOR4
        LJMP fim_valor_pgto

    elseif4_pgto:
        MOV A, #05H
        cjne A, B, elseif5_pgto
        MOV DPTR,#VALOR5
        LJMP fim_valor_pgto

    elseif5_pgto:
        MOV DPTR, #VALOR0
        LJMP fim_valor_pgto

    fim_valor_pgto:
        ACALL escreveStringROM

    CALL delay
    CALL delay
    LCALL PREP ; prepara o café após pagamento concluído
    ret

; Pontes para algumas rotinas distantes da função de leitura do teclado (corrigir out of range)
PAGAR:
    LCALL pagamento
    RET
pouco_jump:
    LCALL POUCO
    RET
total_tela_jump:
    LCALL TOTAL_TELA
    RET
muito_jump:
    LCALL MUITO
    RET
NOV:
    JMP EXIBICAO
    RET
alvaro:
    LCALL colocaAcucar
    RET

; Função de leitura do teclado matricial (scan das colunas e redirecionamento para as rotinas)
colScan0: ; column-scan subroutine
    JNB P0.4, alvaro ; if col0 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.5, PAGAR ; if col1 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.6, total_tela_jump ; if col2 is cleared - key found
    INC R0 ; otherwise move to next key
    RET ; return from subroutine - key not found
colScan1: ; column-scan subroutine
    JNB P0.4, muito_jump ; if col0 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.5, gotKey ; if col1 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.6, pouco_jump ; if col2 is cleared - key found
    INC R0 ; otherwise move to next key
    RET ; return from subroutine - key not found
colScan2:
    JNB P0.4, NOV ; if col0 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.5, CF_MACHIATTO ; if col1 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.6, CF_MOCHA ; if col2 is cleared - key found
    INC R0 ; otherwise move to next key
    RET ; return from subroutine - key not found
colScan3:
    JNB P0.4, CF_RISTRETTO ; if col0 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.5, CF_ESPRESSO ; if col1 is cleared - key found
    INC R0 ; otherwise move to next key
    JNB P0.6, CF_CAPPUCCINO ; if col2 is cleared - key found
    INC R0 ; otherwise move to next key
    RET ; return from subroutine - key not found
gotKey:
    SETB F0 ; key found - set F0
    RET

; Exibe confirmação do café selecionado (para cada tipo de café) - CF = Confirmação
CF_CAPPUCCINO:
    MOV R4, #03H
    SETB F0
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#CAPPUCCINO
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR
    ACALL escreveStringROM
    RET

CF_ESPRESSO:
    MOV R4, #02H
    SETB F0
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#ESPRESSO
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR
    ACALL escreveStringROM
    RET

CF_RISTRETTO:
    MOV R4, #01H
    SETB F0
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#RISTRETTO
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR
    ACALL escreveStringROM
    RET

CF_MOCHA:
    MOV R4, #04H
    SETB F0
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#MOCHA
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR
    ACALL escreveStringROM
    RET

CF_MACHIATTO:
    MOV R4, #05H
    SETB F0
    ACALL clearDisplay
    MOV A, #02h
    ACALL posicionaCursor
    MOV DPTR,#MACHIATTO
    ACALL escreveStringROM
    MOV A, #41h
    ACALL posicionaCursor
    MOV DPTR,#CONFIRMAR
    ACALL escreveStringROM
    RET

; Configuração do display LCD
; initialise the display
lcd_init:
    CLR RS ; clear RS - indicates that instructions are being sent to the module
    ; function set
    CLR P1.7 ; |
    CLR P1.6 ; |
    SETB P1.5 ; |
    CLR P1.4 ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CALL delay ; wait for BF to clear
    ; function set sent for first time - tells module to go into 4-bit mode
    ; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.
    SETB EN ; |
    CLR EN ; | negative edge on E
    ; same function set high nibble sent a second time
    SETB P1.7 ; low nibble set (only P1.7 needed to be changed)
    SETB EN ; |
    CLR EN ; | negative edge on E
    ; function set low nibble sent
    CALL delay ; wait for BF to clear
    ; entry mode set
    ; set to increment with no shift
    CLR P1.7 ; |
    CLR P1.6 ; |
    CLR P1.5 ; |
    CLR P1.4 ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    SETB P1.6 ; |
    SETB P1.5 ; |low nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CALL delay ; wait for BF to clear
    ; display on/off control
    ; the display is turned on, the cursor is turned on and blinking is turned on
    CLR P1.7 ; |
    CLR P1.6 ; |
    CLR P1.5 ; |
    CLR P1.4 ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    SETB P1.7 ; |
    SETB P1.6 ; |
    SETB P1.5 ; |
    SETB P1.4 ; | low nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CALL delay ; wait for BF to clear
    RET

; Função que manda os caracteres da string para o display
sendCharacter:
    SETB RS ; setb RS - indicates that data is being sent to module
    MOV C, ACC.7 ; |
    MOV P1.7, C ; |
    MOV C, ACC.6 ; |
    MOV P1.6, C ; |
    MOV C, ACC.5 ; |
    MOV P1.5, C ; |
    MOV C, ACC.4 ; |
    MOV P1.4, C ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    MOV C, ACC.3 ; |
    MOV P1.7, C ; |
    MOV C, ACC.2 ; |
    MOV P1.6, C ; |
    MOV C, ACC.1 ; |
    MOV P1.5, C ; |
    MOV C, ACC.0 ; |
    MOV P1.4, C ; | low nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CALL delay ; wait for BF to clear
    CALL delay ; wait for BF to clear
    RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereï¿½o da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
    CLR RS
    SETB P1.7 ; |
    MOV C, ACC.6 ; |
    MOV P1.6, C ; |
    MOV C, ACC.5 ; |
    MOV P1.5, C ; |
    MOV C, ACC.4 ; |
    MOV P1.4, C ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    MOV C, ACC.3 ; |
    MOV P1.7, C ; |
    MOV C, ACC.2 ; |
    MOV P1.6, C ; |
    MOV C, ACC.1 ; |
    MOV P1.5, C ; |
    MOV C, ACC.0 ; |
    MOV P1.4, C ; | low nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CALL delay ; wait for BF to clear
    CALL delay ; wait for BF to clear
    RET

; Retorna o cursor para primeira posiï¿½ï¿½o sem limpar o display
retornaCursor:
    CLR RS
    CLR P1.7 ; |
    CLR P1.6 ; |
    CLR P1.5 ; |
    CLR P1.4 ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CLR P1.7 ; |
    CLR P1.6 ; |
    SETB P1.5 ; |
    SETB P1.4 ; | low nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CALL delay ; wait for BF to clear
    RET

; Limpa o display
clearDisplay:
    CLR RS
    CLR P1.7 ; |
    CLR P1.6 ; |
    CLR P1.5 ; |
    CLR P1.4 ; | high nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    CLR P1.7 ; |
    CLR P1.6 ; |
    CLR P1.5 ; |
    SETB P1.4 ; | low nibble set
    SETB EN ; |
    CLR EN ; | negative edge on E
    MOV R2, #40

rotC:
    CALL delay ; wait for BF to clear
    DJNZ R2, rotC
    RET

; Rotina de delay
delay:
    MOV R0, #20
    DJNZ R0, $
    RET

; Rotina de delay para preparação do café (duração maior) - 1
delay_preparing:
    MOV R0, #8
    bring_delay:
    ACALL delay_preparing2
    DJNZ R0, bring_delay
    RET

; Rotina de delay para preparação do café (duração maior) - 2
delay_preparing2:
    MOV R3, #255
    DJNZ R3, $
    RET