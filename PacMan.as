;===============================================================================
; Programa PacMan.as
;
; Descricao: Implementa��o do jogo PacMan para Assembly do P3
;
;
; Autor: João ALmeida 90119 & Rafael Cordeiro 90171 , grupo 57
; Data: 05/2018 				 
;===============================================================================

;===============================================================================
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;===============================================================================
; GAME SYMBOLS
PAC_MAN		EQU	'@'
MONSTER		EQU	'X'
BONUS		EQU	'#'
NOTHING		EQU ' '

; RAMDOM_MASK	
RAMDOM_MASK		EQU	1001110000010110b

; STACK POINTER
SP_INICIAL      EQU     FDFFh

; I/O a partir de FF00H
DISP7S1         EQU     FFF0h
DISP7S2         EQU     FFF1h
DISP7S3         EQU     FFF2h
LCD_WRITE		EQU		FFF5h
LCD_CURSOR		EQU		FFF4h	
LEDS            EQU     FFF8h
INTERRUPTORES   EQU     FFF9h
IO_CURSOR       EQU     FFFCh
IO_WRITE        EQU     FFFEh

LIMPAR_JANELA   EQU     FFFFh
FIM_TEXTO       EQU     '$'

; INTERRUPCOES
TAB_INT0        EQU     FE00h
TAB_INT2        EQU     FE02h
TAB_INT4        EQU     FE04h
TAB_INT6        EQU     FE06h
TAB_INT8        EQU     FE08h
TAB_INTA        EQU     FE0Ah
TAB_INTB        EQU     FE0Bh
TAB_INTC        EQU     FE0Ch
TAB_INTTemp     EQU     FE0Fh
PORTMASCARA_INT	EQU		FFFAh

; TEMPORIZADOR
TempValor		EQU		FFF6h
TempControlo	EQU		FFF7h

;===============================================================================
; ZONA II: Definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres.
;          Cada caracter ocupa 1 palavra
;===============================================================================
                ORIG    8000h

PacMan			STR     0820h, 0820h	;posição do PacMan atual, nao interessa para nada, perguntar ao ilic
Monsters		STR		0101h, 0D01h, 0130h, 0D30h	
MonstersOLD		STR		0101h, 0D01h, 0130h, 0D30h
BONUS_POS		WORD	0C23h		;posição do ponto bonus
SUPER_PacMan	WORD	0000h		;indinca se o pacman pode comer monstros ou nao
BONUS_TEMP		WORD	0000h		;indica quando o ponto bonus deveria estar avito
CountDown		STR		0200h, 0200h
Mexe_PacMan		WORD    0000h
PacMan_Vidas	STR		0003h, 0003h
Num_Monsters	WORD	0004h
Score			STR		0000h, 0000h
LCD_POS			STR		8000h, 800Fh, 8014h, 801Fh	;posição de escrita no LCD
MODO			WORD	0000h
RandomWord		WORD		RAMDOM_MASK
						;tabuleiro cópia
VLinha1         STR     '--------------------------------------------------', FIM_TEXTO
VLinha2         STR     '|................................................|', FIM_TEXTO
VLinha3         STR     '|...__________......__________......__________...|', FIM_TEXTO
VLinha4         STR     '|...|__    __|......|    ____|......|__    __|...|', FIM_TEXTO
VLinha5         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha6         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO
VLinha7         STR     '|......|  |.........|   |____ .........|  |......|', FIM_TEXTO
VLinha8         STR     '|......|  |.........|____    |.........|  |......|', FIM_TEXTO
VLinha9         STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha10        STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO
VLinha11        STR     '|... __|  |__ ...... ____|   |.........|  |......|', FIM_TEXTO
VLinha12        STR     '|...|________|......|________|.........|__|......|', FIM_TEXTO
VLinha13        STR     '|................................................|', FIM_TEXTO
VLinha14        STR     '|................................................|', FIM_TEXTO
VLinha15        STR     '--------------------------------------------------', FIM_TEXTO
						;tabuleiro original
TLinha1         STR     '--------------------------------------------------', FIM_TEXTO
TLinha2         STR     '|................................................|', FIM_TEXTO;48
TLinha3         STR     '|...__________......__________......____  ____...|', FIM_TEXTO;18
TLinha4         STR     '|...|__    __|......|       _|......|__    __|...|', FIM_TEXTO;18
TLinha5         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO;35
TLinha6         STR     '|......|  |.........|   |..............|  |......|', FIM_TEXTO;35
TLinha7         STR     '|......|  |.........|   |____ .........|  |......|', FIM_TEXTO;30
TLinha8         STR     '|......    .........|_       |.........|  |......|', FIM_TEXTO;30
TLinha9         STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO;35
TLinha10        STR     '|......|  |..............|   |.........|  |......|', FIM_TEXTO;35
TLinha11        STR     '|... __|  |___...... ____|   |.........|  |......|', FIM_TEXTO;24
TLinha12        STR     '|...|_________|.....|___    _|.........|  |......|', FIM_TEXTO;24
TLinha13        STR     '|................................................|', FIM_TEXTO;48
TLinha14        STR     '|................................................|', FIM_TEXTO;48	Total = 428d - bonus= 427d
TLinha15        STR     '--------------------------------------------------', FIM_TEXTO;		= 01ABh
Mensagem		STR		'Pressione: int IA ou B para o modo basico, ou int IB ou A para o modo avancado', FIM_TEXTO
Titulo			STR		'*** PAC_MAN (MEEC 17/18) ***', FIM_TEXTO
Perdi    		STR 	'***--------O jogo acabou--------***',FIM_TEXTO
INFO    		STR  	'***CARREGUE EM I0 PARA REINICIAR***',FIM_TEXTO
Vidas			STR		'#Vidas: ', FIM_TEXTO
Pontos			STR		'#Pontos: ', FIM_TEXTO
LCDLinha0		STR		'GAME_TIME: ',FIM_TEXTO
LCDLinha1		STR		'Rank1: ',FIM_TEXTO
RITMO  			STR  	000Ah,0006h,0003h,0001h ;Ritmo dos monstros
Clock_Tic		WORD	0001h		;velociade do clock de relogio
Clock			WORD	0001h
N_to_Display	STR		0079h, 0079h	;tempo restante e tempo inicial
Update_Display	WORD	0000h
Pausa			WORD	0000h
Particulas		STR	 	01ABh, 01ABh		;nr de partículas a mostrar tabuleiro e o nr de partículas inical

;===============================================================================
; ZONA III: Codigo
;           conjunto de instrucoes Assembly, ordenadas de forma a realizar
;           as funcoes pretendidas
;===============================================================================
                ORIG    0000h
				MOV		R1, SP_INICIAL
				MOV		SP, R1
                JMP     inicio

;===============================================================================
; Pausa: Rotina de interrupcao 0
;	interrupção que permite pausar o jogo
;===============================================================================
Pausa_Pac:  NOP
			PUSH	R1
			MOV		R1, M[Pausa]
			XOR		R1, 0001h
			MOV		M[Pausa], R1
			POP		R1
        	RTI

;===============================================================================
; MoveDown_Pac: 
;	rotina que permite ao pacman mover-se para baixo
;===============================================================================
MoveDown_PacMan:  	NOP	; completar rotina de atendimento da int 8
					PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R7		
					MOV		R1, M[PacMan]
					MOV		R3, R1
					ADD		R1, 0100h
					CALL	Validar_Jogadas
					CMP		R7, 0000h
					BR.Z	FIM_Do_MoveDown_Pac
					CALL	Atualizar_Posicao_PacMan
					;jogada válida
					CALL	Ponto_Bonus
					MOV		R1, M[PacMan]
					MOV		R1, R3
					;remoção do ponto
					;cada partícual que o PacMan come, o jogador ganha 1 pontos
					PUSH	R7
					MOV		R7, 1
					CALL	remove_ponto
					POP		R7
	FIM_Do_MoveDown_Pac:	NOP
					POP		R7
					POP		R3
					POP		R2
					POP		R1
					RET

;===============================================================================
; MoveDown_Pamman: Rotina de interrupcao 2
;	interrupção que permite saber quando o movimento pretendido irá ser para baixo
;===============================================================================
MoveDown_Pac:   NOP	
                PUSH	R1
				MOV		R1, 0002h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; MoveLeft_PacMan: TODO
;	rotina que permite ao pacman mover-se para a esquerda
;===============================================================================
MoveLeft_PacMan:  	NOP	; completar rotina de atendimento da int 4
					PUSH	R1
					PUSH 	R7
					MOV		R1, M[PacMan]
					SUB		R1, 0001h
					CALL	Validar_Jogadas
					CMP		R7, 0000h
					BR.Z	FIM_Do_MoveLeft_Pac
					CALL	Atualizar_Posicao_PacMan
					;jogada válida
					CALL	Ponto_Bonus
					MOV		R1, M[PacMan]
					ADD		R1, 0001h	
					;remoção do ponto
					;cada partícual que o PacMan come, o jogador ganha 1 pontos
					PUSH	R7
					MOV		R7, 1
					CALL	remove_ponto
					POP		R7
	FIM_Do_MoveLeft_Pac:	NOP
					POP		R7
					POP		R1
					RET

;===============================================================================
; MoveLeft_Pac: Rotina de interrupcao 4
;	interrupção que permite saber quando o movimento pretendido irá ser para a esquerda
;===============================================================================
MoveLeft_Pac:   NOP	; completar rotina de atendimento da int 4
                PUSH	R1
				MOV		R1, 0004h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; MoveRight_Pac:
;	rotina que permite ao pacman mover-se para a direita
;===============================================================================
MoveRight_PacMan:  	NOP	; completar rotina de atendimento da int 6
					PUSH	R1
					PUSH	R7
					MOV		R1, M[PacMan]
					ADD		R1, 0001h
					CALL	Validar_Jogadas
					CMP		R7, 0000h
					BR.Z	FIM_Do_MoveRight_Pac
					CALL	Atualizar_Posicao_PacMan
					;jogada válida 
					CALL	Ponto_Bonus
					MOV		R1, M[PacMan]
					SUB		R1, 0001h
					;remoção do ponto
					;cada partícual que o PacMan come, o jogador ganha 1 pontos
					PUSH	R7
					MOV		R7, 1
					CALL	remove_ponto
					POP		R7
	FIM_Do_MoveRight_Pac:	NOP
					POP		R7
					POP		R1
					RET
;===============================================================================
; MoveRight_Pamman: Rotina de interrupcao 6
;	interrupção que permite saber quando o movimento pretendido irá ser para a direita
;===============================================================================
MoveRight_Pac:  NOP	
                PUSH	R1
				MOV		R1, 0006h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI

;===============================================================================
; MoveUp_Pac:
;	rotina que permite ao pacman mover-se para cima
;===============================================================================
MoveUp_PacMan:     	NOP	; completar rotina de atendimento da int 8
					PUSH	R1
					PUSH	R7
					MOV		R1, M[PacMan]
					SUB		R1, 0100h
					CALL	Validar_Jogadas
					CMP		R7, 0000h
					BR.Z	FIM_Do_MoveUp_Pac
					CALL	Atualizar_Posicao_PacMan
					;jogada válida
					CALL	Ponto_Bonus
					MOV		R1, M[PacMan]
					ADD		R1, 0100h
					;remoção do ponto
					;cada partícual que o PacMan come, o jogador ganha 1 pontos
					PUSH	R7
					MOV		R7, 1
					CALL	remove_ponto
					POP		R7	
	FIM_Do_MoveUp_Pac:		NOP
					POP		R7
					POP		R1
					RET

;===============================================================================
; MoveUp_Pamman: Rotina de interrupcao 8
;	interrupção que permite saber quando o movimento pretendido irá ser para cima
;===============================================================================
MoveUp_Pac:   	NOP	
				PUSH	R1
				MOV		R1, 0008h
				MOV		M[Mexe_PacMan], R1
				POP		R1
				RTI
;===============================================================================
; Timer: Rotina de interrupcao 15
;
;===============================================================================
Temp_Pac:	NOP	; completar rotina de atendimento da int 15
			PUSH 	R1
			PUSH    R2
			MOV		R2, M[Clock]
			MOV		R1, M[Clock_Tic]
			MOV		M[TempValor], R1
			MOV		R1, 1
			MOV		M[TempControlo], R1
			CMP		R2, 000Ah
			BR.NZ	end_
			;quando passa um segundo
			MOV		M[Clock], R0
			MOV		M[Update_Display], R1		
	end_:	MOV		R2, M[Clock]	
			INC		R2
			MOV		M[Clock], R2
			POP		R2
			POP		R1
			RTI

;===============================================================================
; Modo_basico: Rotina de interrupcao 10
;
;===============================================================================
Modo_basico:	NOP	
				PUSH 	R1
				MOV		R1, 0001h
				MOV 	M[MODO], R1
				POP		R1
				RTI
;===============================================================================
; Modo_avancado: Rotina de interrupcao 11
;
;===============================================================================
Modo_avancado:	NOP	
				PUSH 	R1
				MOV		R1, 0010h
				MOV 	M[MODO], R1
				POP		R1
				RTI

;===============================================================================
; Remove um ponto
;	rotina que permite remover um ponto tanto do tabuleiro como da memória
;===============================================================================
remove_ponto:  		NOP	
					PUSH	R1		;caratere a escrever e posição do ponto
					PUSH	R4
					PUSH	R3
					PUSH	R2
					PUSH	R5
					PUSH	R6		;posição do ponto BackUp
					MOV		R6,R1
					;decremento o número de partículas no tabuleiro
					MOV		R2, VLinha1
					MOV		R3, R1
					MOV		R4, R1
					MOV		R5, 51
					;coordenada xx
					AND		R3, 00FFh
					SHR		R4, 8
					;cooredana	yy
					MUL		R4, R5
					ADD		R5, R3
					ADD		R5, R2
					MOV		R2, M[R5]
					CMP		R2, '.'
					BR.NZ	FIM_REMOVE
					;remove da memória
					MOV		R1, NOTHING
					MOV		M[R5], R1
					;decremento o nr de partículas que faltam
					MOV		R2, M[Particulas]
					DEC		R2
					MOV		M[Particulas], R2
					;aumenta a pontuação do jogador caso tenha sido
					;o pacman a comer a partícula
					CMP		R7, 0
					BR.Z	FIM_REMOVE
					MOV		R1, 1
					CALL	RenderScore
					;remove o ponto do tabuleiro e da memória
	FIM_REMOVE:		MOV		M[IO_CURSOR], R6
					MOV		R1, NOTHING
					CALL	EscCar
					POP		R6
					POP		R5
					POP		R2
					POP		R3
					POP		R4
					POP		R1
					RET
;===============================================================================
; Ponto_Bonus
;			rotina de ativação do modo super pacman
;===============================================================================
Ponto_Bonus:    NOP	
                PUSH	R2
				;se estiver o ponto bonus ativo
				MOV		R2, M[BONUS_TEMP]
				CMP		R2, 1
				BR.NZ	Fim_Bonus
				;se a posição desejada pelo pacman for a mesma do ponto bonus
				MOV		R2, M[BONUS_POS]
				CMP		R2, R1
				BR.NZ	Fim_Bonus
				;estado dois, significa que o ponto foi comido
				MOV		R2, 2
				MOV		M[BONUS_TEMP], R2
				MOV		R2, 1
				MOV		M[SUPER_PacMan], R2
	Fim_Bonus:	POP		R2
				RET

;===============================================================================
; 					BONUS_COMIDA: 
;	M[BONUS_TEMP] = 0 quando o ponto nao deve estar ativo
;					1 quando o ponto está ativo
;					2 quando o ponto está ativo mas o pacman comeu o ponto
;===============================================================================
BONUS_COMIDA:		PUSH	R1
					PUSH	R2
					MOV		R2, M[N_to_Display]			;tem o valor do tempo atual

	LOOP_clock:		SUB		R2, 000Ah
					BR.Z	IMPRIME
					BR.NN	LOOP_clock
					JMP		FIM_BONUS

	IMPRIME:		NOP
					;se tiver impresso um ponto bonus antes
					MOV		R2, 0000h
					CMP		M[BONUS_TEMP], R2
					BR.NZ	PRINT_NADA		;se nao for zero quer dizer que o ponto devia de ter estado ativo
					;se impresso um espaço em branco antes
					BR		PRINT_BONUS

	PRINT_NADA:		NOP
					MOV		R1, M[BONUS_POS]
					MOV		M[IO_CURSOR], R1
					MOV		R1, NOTHING
					CALL 	EscCar
					MOV		R1, 0000h
					MOV		M[BONUS_TEMP], R1
					BR		FIM_BONUS

	PRINT_BONUS:	NOP
					MOV		R1, M[BONUS_POS]
					MOV		M[IO_CURSOR], R1
					MOV		R1, BONUS
					CALL 	EscCar
					MOV		R1, 0001h
					MOV		M[BONUS_TEMP], R1
					BR		FIM_BONUS

	FIM_BONUS:		POP 	R2
					POP		R1
					RET

;===============================================================================
; PacMan_Comeu_Bicho?:
;	Rotina que compara as posições dos monstros com a do pacman e transmite se há conflito ou não
;===============================================================================
PacMan_Comeu_Bicho?:	NOP
						PUSH 	R1
						PUSH	R2
						PUSH	R3
						MOV		R3, 3
						MOV		R1, M[PacMan]
						;procurar se a posição do pacman coincide com algum bicho
		loop_bicho:		MOV		R2, M[R3 + Monsters]
						CMP		R1, R2
						BR.Z	mesma_posicao
						DEC		R3
						BR.NN	loop_bicho
						BR		exit_success
						;para já não vou contar com super PacMan
		mesma_posicao:	MOV		R1, M[SUPER_PacMan]
						CMP		R1, R0
						BR.Z	morte_pac
						CALL.NZ	O_Super_PacMan_comeu_o_bicho
						BR		exit_success
			morte_pac:	CALL	O_PacMan_foi_comido_pelo_bicho
		exit_success:	POP		R3
						POP		R2
						POP		R1
						RET
;===============================================================================
; O_Super_PacMan_comeu_o_bicho:
;	Rotina que identifica os casos em que o SUPER pacman comeu um monstro
;===============================================================================
O_Super_PacMan_comeu_o_bicho:	NOP
						PUSH 	R1
						;R3 tem o numero do monstro comido
						MOV		R2, M[R3 + MonstersOLD]
						MOV		M[R3 + Monsters], R2
						;cada vez que come um monstro o jogador ganha 20 pontos
						MOV		R1, 20
						CALL	RenderScore
						POP		R1
						RET

;===============================================================================
; O_PacMan_foi_comido_pelo_bicho:
;	Rotina que identifica os casos em que o pacman foi comido por um monstro
;===============================================================================
O_PacMan_foi_comido_pelo_bicho:		NOP
									PUSH	R1
									PUSH	R2
									PUSH	R3
									;decrementa o número de vidas
									MOV		R3, M[PacMan_Vidas]
									DEC		R3
									MOV		M[PacMan_Vidas], R3
									CMP		R3, R0
									JMP.Z	Print_Stats
									;imprimir o monstro
									MOV		M[IO_CURSOR], R2
									MOV		R1, MONSTER
									CALL	EscCar
									;voltar à posição inicial
									MOV		R3, 1
									MOV		R3, 3
				bichos_reset:		MOV		R1, NOTHING
									MOV		R2, M[R3 + Monsters]
									MOV		M[IO_CURSOR], R2
									CALL	EscCar
									MOV		R2, M[R3 + MonstersOLD]
									MOV		M[R3 + Monsters], R2
									DEC		R3
									MOV		R1, MONSTER
									MOV		R2, M[R3 + Monsters]
									MOV		M[IO_CURSOR], R2
									CALL	EscCar
									BR.NN	bichos_reset
									MOV		R2, M[R3 + PacMan]
									MOV		M[PacMan], R2
									MOV		M[IO_CURSOR], R2
									MOV		R1, PAC_MAN
									CALL	EscCar
									POP		R3
									POP		R2
									POP		R1
									RET

;===============================================================================
; 					CountDown10:
;		Esta função vai apenas agir qunaodo o pacman como um ponto bonus
;	Rotina de escrita nas leds, do nr de segundos que falta pata acabar o modo Super_PacMan
;===============================================================================
CountDown10:			PUSH	R1
						MOV		R1, M[SUPER_PacMan]
						CMP		R1, 0001h
						BR.NZ	PacMan_normal	
						;==== Escrita nos LEDS ====
						MOV		R1, M[CountDown]
						MOV		M[LEDS], R1
						SHR		R1, 1
						BR.NZ	guarda_valor
						MOV		R1, 1
						MOV		R1, M[R1 + CountDown]
						MOV		M[SUPER_PacMan], R0
	guarda_valor:		MOV		M[CountDown], R1
						BR		FIM_countdown
	PacMan_normal:		MOV		M[LEDS], R0
	FIM_countdown:		POP		R1
						RET

;===============================================================================
; Validar_Jogada:
;		
;		R1 - posição pacman
;		R2 - posição no tabuleiro
;		R3 - posição xx do movimento 
;		R4 - posição yy do movimento
;		R5 - tamanho da string
;		R7 - bool jogada válida
;
;	Rotina que permite avaliar se a jogada é válida ou não
;===============================================================================
Validar_Jogadas:	NOP
					PUSH	R5
					PUSH	R4
					PUSH	R3
					PUSH	R2
					MOV		R7, 0
					;confirmar que não passa nenhuma fronteira
					MOV		R2, VLinha1
					MOV		R3, R1
					MOV		R4, R1
					MOV		R5, 51
					;coordenada xx
					AND		R3, 00FFh
					SHR		R4, 8
					;cooredana	yy
					MUL	R4, R5
					ADD		R5, R3
					ADD		R5, R2
					MOV		R2, M[R5]
					CMP		R2, '-'
					BR.Z	FIM
					CMP		R2, '|'
					BR.Z	FIM
					CMP		R2, '_'
					BR.Z	FIM
					MOV		R7, 1
	FIM:			POP		R2
					POP		R3
					POP		R4
					POP 	R5
					RET						

;===============================================================================
; Atualizar_Posicao_PacMan:
;	Rotina que escreve o PacMan no novo sitio do tabueleiro
;===============================================================================
Atualizar_Posicao_PacMan:	NOP
							PUSH	R1
							;jogada válida , atualização da posição do PacMan
							MOV		M[PacMan], R1
							MOV		M[IO_CURSOR], R1
							MOV		R1, PAC_MAN
							CALL	EscCar
							POP		R1
							RET	
;===============================================================================
; Atualizar_Posicao_Monstro:
;recebe em R1 a nova posição do monstro
;	Rotina que escreve o Monstro no novo sitio do tabueleiro, se
;		jogada válida e a posição pretendida não tem monstro		
;
;	TODO	atualizar a nova posição do monstro 
;===============================================================================
Atualizar_Posicao_Monstro:	NOP
							PUSH	R1
							PUSH	R2
							;se a posição pretendida pelo monstro já tiver outro monstro
							MOV		R2, 0003h
	LOOP_POS_MONSTRO:		CMP		R1, M[R2 + Monsters]
							BR.Z	FIM_POS_MONSTRO
							DEC		R2
							BR.NN	LOOP_POS_MONSTRO
							MOV		M[R5 + Monsters], R1
							MOV		M[IO_CURSOR], R1
							MOV		R1, MONSTER
							CALL	EscCar
	FIM_POS_MONSTRO:		POP		R2
							POP		R1
							RET	
;===============================================================================
; modo_de_jogo:
;	seleciona o modo de jogo do utilizador
;===============================================================================
modo_de_jogo:	NOP
							PUSH	R1
							MOV		R1, M[MODO]
							CMP		R1, 0001h
							BR.Z	modo_basico
							CALL	modo_inteligente
							BR		fim_funcao
		modo_basico:		CALL 	MOV_Aleat
		fim_funcao:			POP		R1
							RET	
;===============================================================================
; modo_inteligente:
;	escolhe aleatoriamente uma direção a tomar e alminha -se pela outra
;===============================================================================
modo_inteligente:			NOP	
							PUSH	R1
							PUSH	R2
							PUSH	R5
							MOV		R5, 3
		ciclo_monstros:		MOV		R1, M[R5 + Monsters]
							CALL	Random_Gen
							MOV		R2, M[RandomWord]
							AND		R2, 0001h
							;Caso o bit de menor peso seja 1 o pacman move-se na vertical e ajusta a posição 
							BR.Z	vertical
							;horizontal
							CALL	modo_inteligente_xx
							BR		fim_inteligente
		vertical:			CALL	modo_inteligente_yy
	fim_inteligente:		DEC		R5
							JMP.NN	ciclo_monstros
							POP		R5
							POP		R2
							POP		R1
							RET

;===============================================================================
; modo_inteligente_xx:
;	vai permitir aos monstros alinhar-se pelo eixo dos xx com o pacman
;		R1 :: posição dos monstros (yyxx)
;===============================================================================
modo_inteligente_xx:		NOP
							PUSH	R2;posição do pacman (xx)
							PUSH	R4;posição dos monstros (yyxx)
							PUSH	R3;posição monstro backup (yyxx)
							PUSH	R7
							MOV		R2, M[PacMan]
							AND		R2, 00FFh
	ciclo_monstros_xx:		NOP
							MOV		R4, R1
							MOV		R3, R1
							AND		R4, 00FFh
							CMP		R2, R4 ;se R2, for maior que R1 o pacman encontra-se à direita dos monstros 
							BR.P	move_right
							BR.N	move_left
							JMP		fim_modo_int_xx
			move_right:		ADD		R1, 0001h
							CALL	Validar_Jogadas
							CMP		R7, 0000h
							JMP.Z	fim_modo_int_xx
							CALL	Atualizar_Posicao_Monstro
							MOV		R1, R3
							PUSH	R7
							MOV		R7, 0
							CALL	remove_ponto
							POP		R7
							BR		fim_modo_int_xx
			move_left:		SUB		R1, 0001h
							CALL	Validar_Jogadas
							CMP		R7, 0000h
							BR.Z	fim_modo_int_xx
							CALL	Atualizar_Posicao_Monstro
							MOV		R1, R3
							PUSH	R7
							MOV		R7, 0
							CALL	remove_ponto
							POP		R7
		fim_modo_int_xx:	NOP
							POP		R7	
							POP		R3
							POP		R4
							POP		R2
							RET
;===============================================================================
; modo_inteligente_yy:
;	vai permitir aos monstros alinhar-se pelo eixo dos yy com o pacman
;		R1 :: posição dos monstros (yyxx)
;===============================================================================
modo_inteligente_yy:		NOP
							PUSH	R2;posição do pacman (yy)
							PUSH	R4;posição dos monstros (yyxx)
							PUSH	R3;posição monstro backup (yyxx)
							PUSH	R7
							MOV		R2, M[PacMan]
							SHR		R2, 8
	ciclo_monstros_yy:		NOP
							MOV		R4, R1
							MOV		R3, R1
							SHR		R4, 8
							CMP		R2, R4 ;se R2, for maior que R1 o pacman encontra-se à direita dos monstros 
							BR.P	move_down
							BR.N	move_up
							JMP		fim_modo_int_yy
			move_down:		ADD		R1, 0100h
							CALL	Validar_Jogadas
							CMP		R7, 0000h
							JMP.Z	fim_modo_int_yy
							CALL	Atualizar_Posicao_Monstro
							MOV		R1, R3
							PUSH	R7
							MOV		R7, 0
							CALL	remove_ponto
							POP		R7
							BR		fim_modo_int_yy
			move_up:		SUB		R1, 0100h
							CALL	Validar_Jogadas
							CMP		R7, 0000h
							BR.Z	fim_modo_int_yy
							CALL	Atualizar_Posicao_Monstro
							MOV		R1, R3
							PUSH	R7
							MOV		R7, 0
							CALL	remove_ponto
							POP		R7
		fim_modo_int_yy:	NOP
							POP		R7
							POP		R3
							POP		R4
							POP		R2
							RET
;===============================================================================
; EscDisplay: Rotina que efectua escrita no DISPLAY de 7 segmentos
;               Entradas: R1 - Valor a enviar para o porto do DISPLAY
;                         R2 - Porto do DISPLAY a utilizar
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria/porto M[R2]
;===============================================================================
EscDisplay:     MOV     M[R2], R1
                RET

;===============================================================================
; LimpaJanela: Rotina que limpa a janela de texto.
;               Entradas: --
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
LimpaJanela:    PUSH 	R2
                MOV     R2, LIMPAR_JANELA
		MOV     M[IO_CURSOR], R2
                POP 	R2
                RET

;===============================================================================
; EscCar: Rotina que efectua a escrita de um caracter para o ecran.
;         O caracter pode ser visualizado na janela de texto.
;               Entradas: R1 - Caracter a escrever
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[IO]
;===============================================================================
EscCar:     MOV     M[IO_WRITE], R1
            RET  

;===============================================================================
; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;            pelo caracter FIM_TEXTO, na janela de texto numa posicao 
;            especificada. Pode-se definir como terminador qualquer caracter 
;            ASCII. 
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
EscString:      PUSH    R1
                PUSH    R2
				PUSH    R3
                MOV     R2, M[SP+6]   ; Apontador para inicio da "string"
                MOV     R3, M[SP+5]   ; Localizacao do primeiro carater
	Ciclo:      MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                CALL    EscCar
                INC     R2
                INC     R3
                BR      Ciclo
	FimEsc:     POP     R3
                POP     R2
                POP     R1
                RETN    2                ; Actualiza STACK
;===============================================================================
; EscCar_lcd: Rotina que efectua a escrita de um caracter para o lcd.
;         O caracter pode ser visualizado no lcd verde.
;               Entradas: R1 - Caracter a escrever
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[IO]
;===============================================================================
EscCar_lcd:     MOV     M[LCD_WRITE], R1
            	RET  

;===============================================================================
; EscString_lcd: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;            pelo caracter FIM_TEXTO, no ecra verde do lcd numa posicao 
;            especificada. Pode-se definir como terminador qualquer caracter 
;            ASCII. 
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
EscString_lcd:      PUSH    R1
					PUSH    R2
					PUSH    R3
					MOV     R2, M[SP+6]   ; Apontador para inicio da "string"
					MOV     R3, M[SP+5]   ; Localizacao do primeiro carater
	Ciclo_lcd:      MOV     M[LCD_CURSOR], R3
					MOV     R1, M[R2]
					CMP     R1, FIM_TEXTO
					BR.Z    FimEsc_lcd
					CALL    EscCar_lcd
					INC     R2
					INC     R3
					BR      Ciclo_lcd
	FimEsc_lcd:     POP     R3
					POP     R2
					POP     R1
					RETN    2                ; Actualiza STACK

;===============================================================================
; CLRLCD: Rotina para limpar LCD
;               Entradas:  
;               Saidas:    
;               Efeitos: 
;===============================================================================
CLRLCD:         PUSH    R1
                MOV     R1, 8020h
				MOV	M[LCD_CURSOR], R1
                POP     R1
                RET

;===============================================================================
; Print_Labi: 
;===============================================================================

; Este c�digo refere-se apenas ao exemplo PacMan_Help1 n�o ao projecto
; Como mostrar o labirinto na janela de texto (24 Linhas e 80 Colunas)?
; Uma possibilidade ... mas durante o jogo apenas devem ser alterada as posi��es 
; ... afectadas pelo movimento - manter tanto a mem�ria como a Janela de Texto actualizada
Print_Labi:				PUSH		R1
						PUSH		R2
						PUSH 		R3
						PUSH		R4
						MOV			R1, VLinha1
						MOV			R2, VLinha2
						MOV			R3, 15
						MOV 		R4, 0000h
						SUB			R2,	R1
	Loop_labirinto:		PUSH		R1
						PUSH		R4
						CALL		EscString
						ADD			R4, 0100h
						ADD			R1, R2
						DEC			R3
						BR.NZ		Loop_labirinto
						POP			R4
						POP			R3
						POP			R2
						POP			R1
						RET		
	; Fim de mostrar o labirinto na janela de texto.

;===============================================================================
;Reset_Labi
;	Rotina que cria uma copia do tabuleiro origianal
;===============================================================================
Reset_Labi:		NOP
				PUSH	R1
				PUSH	R2
				PUSH	R3
				PUSH	R4
				MOV		R1, VLinha1
				MOV		R2, TLinha1
				SUB		R2, R1
				MOV		R3, R0
	LOOP_LABI:	MOV		R4, M[R3 + TLinha1]
				MOV		M[R3 + VLinha1], R4
				INC		R3
				CMP		R3, R2
				BR.NZ	LOOP_LABI
				CALL	Print_Labi
				POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET

;===============================================================================
; Print_Stats: 
;		implementa o número de vidas e numero de pontos na janela de texto
;TODO - melhorar para um loop
;===============================================================================
Print_Stats:	PUSH		R1
				PUSH		R2
				PUSH		R3
				PUSH		R4
				;escrever o titulo na janela de texto
				MOV			R3, 1000h
				PUSH		Titulo
				PUSH		R3
				CALL		EscString
				;escrever o numero de vidas na janela de texto
				ADD 		R3, 0100h
				PUSH		Vidas
				PUSH		R3
				CALL		EscString
				MOV			R4, 110Ah	;posição na janela de texto
				MOV			M[IO_CURSOR], R4
				MOV			R1, M[PacMan_Vidas]
				MOV			R2, R1
				ADD			R1, '0'
				CALL		EscCar
				CMP			R2, R0
				JMP.Z		Fim

				;TODO		LOOP	LOOP	
				;escrever o numero de pontos na janela de texto
				ADD 		R3, 0100h
				PUSH		Pontos
				PUSH		R3
				CALL		EscString		
				;atualização do numero de pontos
				MOV			R4, 120Dh
				MOV			R2, 000Fh
				;MOV			R1, M[Particulas]
				MOV			R1, M[Score]
				CALL		SEPARAR_NUMEROS
				MOV			R3, R1
				DEC			R4
				MOV			M[IO_CURSOR], R4
				AND			R1, 000Fh
				ADD			R1, '0'
				CALL		EscCar
				DEC			R4
				MOV			M[IO_CURSOR], R4
				MOV			R1, R3
				SHR			R1, 4
				AND			R1, 000Fh
				ADD			R1, '0'
				CALL		EscCar
				DEC			R4
				MOV			M[IO_CURSOR], R4
				MOV			R1, R3
				SHR			R1, 8
				AND			R1, 000Fh
				ADD			R1, '0'
				CALL		EscCar
				POP			R4
				POP			R3
				POP			R2
				POP			R1
				RET		
		
;===============================================================================
; Escrita_no_LCD: 
;		apenas escreve no LCD, ou chama funções com calculos auxiliares para escreverem 
;===============================================================================
Escrita_no_LCD:		NOP
					PUSH	R1;informação a escrever
					PUSH	R3; = 1, para poder aceder ao segundo elemeto do vetor
					PUSH	R4; inc para percorrer o vetor posição
					PUSH	R5; auxiliar
					PUSH	R6;entrada da função conversor com a posição de escrita
					MOV		R3, 1
					MOV		R4, 0	;cursor
					;escrita da melhor pontuação
						;string
					MOV		R5, M[R4 + LCD_POS]
					INC		R4
					PUSH	LCDLinha0
					PUSH	R5
					CALL	EscString_lcd
						;valor
					MOV		R1, M[N_to_Display]
					MOV		R6, M[R4 + LCD_POS]
					INC		R4	
					CALL	Conversor_para_ASCII
					;escrita do tempo de jogo 
						;string
					MOV		R5, M[R4 + LCD_POS]
					INC		R4
					PUSH	LCDLinha1
					PUSH	R5
					CALL	EscString_lcd
						;valor
					MOV		R1, M[R3 + Score]
					MOV		R6, M[R4 + LCD_POS]
					CALL	Conversor_para_ASCII
					POP		R6
					POP		R5
					POP		R4
					POP		R3
					POP		R1
					RET
;===============================================================================
; Update_Display: 
;===============================================================================
UpDate_Display:		PUSH	R1
					PUSH	R2
					MOV		M[Update_Display], R0
					MOV		R2, M[N_to_Display]
					DEC 	R2
					CMP		R2, 0
					JMP.N	Fim
					MOV		R1, R2
					CALL	SEPARAR_NUMEROS 
					MOV		M[N_to_Display], R2
					MOV		M[DISP7S1], R1
					ROR		R1, 4
					MOV		M[DISP7S2], R1	
					ROR		R1, 4
					MOV		M[DISP7S3], R1	
					POP		R2
					POP		R1
					RET
;===============================================================================
; SEPARAR_NUMEROS 
;	função converte o nuemro hexadecimal em binário e escreve cada digito em 
;		com 4 bits , i.e : 0064h == 100d ->(SEPARAR_NUMEROS)->	0100h
;		Escreve o resultado final em R1
;===============================================================================
SEPARAR_NUMEROS:			NOP
							PUSH	R3
							PUSH	R2
							MOV 	R3, R1
							MOV		R1, 0
							;saber quando o numero tem tres digitos em decimal
				LCD3:		MOV		R2, 0064h
							;loop para determinar o numero em decimal
			Inc_LCD3:		CMP		R3, R2
							BR.N	LCD2
							SUB		R3, R2
							ADD		R1, 0100h
							BR		Inc_LCD3
				LCD2:		MOV		R2, 000Ah
			Inc_LCD2:		CMP		R3, R2
							BR.N	LCD1
							SUB		R3, R2
							ADD		R1, 0010h
							BR		Inc_LCD2
				LCD1:		MOV		R2, 0001h
			Inc_LCD1:		CMP		R3, R2
							BR.N	FIM_SEPARAR_NUMEROS
							SUB		R3, R2
							ADD		R1, 0001h
							BR		Inc_LCD1
	FIM_SEPARAR_NUMEROS :	POP		R2
							POP		R3
							RET

;==================================================================================
;                 Conversor para ASCII, recebendo em R1, um numero hexadecimal 
;		converte para código ascii apenas entre 0-9 o código em binário
;					Escrita no LCD
;		Recebe como parâmetro de entrada :
;			R6, posição de escrita no LCD (direita)
;			R1, informação a escrever
;==================================================================================
Conversor_para_ASCII:	NOP
						PUSH	R1;		numero em hexa
						PUSH	R2;		numero de digitos
						PUSH	R3;		conversoes de hexa para numero a escrever 
						PUSH	R4;		controlo digito a selecionar
						PUSH	R6;		posição do display
						PUSH	R5;	
						MOV		R2, 0
						MOV		R3, R1
						;saber o numero de digitos em binario
	LOOP_ASCII:			INC		R2
						CMP		R3, 0
						BR.Z	Stage_Two
						SHR		R3, 4
						BR		LOOP_ASCII
	Stage_Two:			CALL	SEPARAR_NUMEROS
						MOV		R4, 000Fh
	Stage_Three:		MOV		R3, R1
						AND		R3, R4
	Bits_na_direita:	MOV		R5, R3
						;só escreve quando o digito a escrever estiver nos quatro bits menos significativos
						AND		R5, FFF0h
						BR.Z	Write_LCD
						SHR		R3, 4
						BR		Bits_na_direita
						;escrita no LCD
		Write_LCD:		ADD		R3, 48
						MOV		M[LCD_CURSOR], R6
						MOV		M[LCD_WRITE], R3
						DEC		R6
						SHL		R4,	4
						DEC		R2
						BR.NZ	Stage_Three
						POP		R5
						POP		R6
						POP		R4
						POP		R3
						POP		R2
						POP		R1
						RET

;===============================================================================
; Random_Gen: Gera um número aleatório que coloca em M[RandomWord]
;===============================================================================
Random_Gen:			PUSH	R1
					PUSH	R2
					MOV		R1, M[RandomWord]
					XOR		R1, RAMDOM_MASK
					ROL		R1, 1
					BR.NZ	FIM_RAND
					BR		PONTO_2R
	PONTO_2R:		OR		R1, 0101h
	FIM_RAND:     	MOV     M[RandomWord],R1
					POP		R2
					POP		R1
					RET

;===============================================================================
; MOV_Aleat: 
;	Rotina que permite gerar o movimento aleatório no modo básico
;===============================================================================
MOV_Aleat:				PUSH	R1
						PUSH	R2
						PUSH	R3
						PUSH	R4
						PUSH	R5
						PUSH	R7
						MOV		R5, 3
						;gera um numero aletaoria e coloca em M[RandomWord]
	Inicio_	:			CALL	Random_Gen
						MOV		R1, M[R5 + Monsters]
						;R2 tem a posição incial
						MOV		R2, R1
						MOV		R3, M[RandomWord]
						AND		R3, 0003h	;só quero as coordenadas
						;se o segundo bit for 1 o monstro move-se na vertical caso contrário move-se na horizontal
						TEST	R3, 0002h
						BR.Z	horizontal
						;vertical	
						MOV		R4, 0100h
						BR		operacao
		horizontal:		MOV		R4, 0001h
						;se o primeiro bit for 0 subtrai-se uma coordenada do pacman, caso contrário adiciona-se
		operacao:		TEST	R3, 0001h
						BR.Z	subtrai
						;adiciona						
						ADD		R1, R4
						BR		continua
		subtrai:		SUB		R1, R4
		continua:		CALL	Validar_Jogadas
						CMP		R7, 0000h
						BR.Z	FIM_Do_MOV_Aleat
						CALL	Atualizar_Posicao_Monstro
						MOV		R1, R2
						;remoção do ponto se não for o pacman
						PUSH	R7
						MOV		R7, 0
						CALL	remove_ponto
						POP		R7
	FIM_Do_MOV_Aleat:	NOP
						MOV		R7, 0
						DEC		R5
						JMP.NN	Inicio_
						NOP
						POP		R7
						POP		R5
						POP		R4
						POP		R3
						POP		R2
						POP		R1
						RET

;===============================================================================
;                                       RESET_VARIÁVEIS: 
;função reset variáveis como por exemplo a posição do pacman, do temp, dos monstros 
;===============================================================================
RESET_VARIAVEIS:		NOP
						PUSH	R1
						PUSH	R2
						MOV		R1, 1
						;reiniciar o número de partículas
						MOV		R2, M[R1 + Particulas]
						MOV		M[Particulas], R2
						;reiniciar a posição do pacman
						MOV		R2, M[R1 + PacMan]
						MOV		M[PacMan], R2
						;reiniciar o tempo
						MOV		R2, M[R1 + N_to_Display]
						MOV		M[N_to_Display], R2
						;reiniciar o countdown
						MOV		R2, M[R1 + CountDown]
						MOV		M[CountDown], R2
						;reiniciar vidas
						MOV		R2, M[R1 + PacMan_Vidas]
						MOV		M[PacMan_Vidas], R2
						;iniciar o número de pontos
						MOV		M[Score], R0
						;reiniciar os monstros
						MOV		R1, 3
	monsters_reset:		MOV		R2, M[R1 + MonstersOLD]
						MOV		M[R1 + Monsters], R2
						DEC		R1
						BR.NN	monsters_reset
						POP		R2
						POP		R1
						RET
;===============================================================================
;                                       RenderBichos:
;	Rotina que faz render os monstros
;===============================================================================
RenderBichos:			PUSH	R1
						PUSH	R2
						PUSH	R3
						PUSH	R4
						MOV		R1, M[PacMan] 
						MOV		M[IO_CURSOR] , R1
						MOV		R1, PAC_MAN
						CALL	EscCar
						;imprimir os monstros
						MOV		R2, R0
						MOV		R4, 4
	Render_Monsters:	MOV		R3, M[R2 + Monsters]
						MOV		M[IO_CURSOR] , R3
						MOV		R1, MONSTER
						CALL	EscCar
						INC		R2
						DEC		R4
						BR.NZ	Render_Monsters
						POP		R4
						POP		R3
						POP		R2
						POP		R1
						RET
;===============================================================================
; RenderScore:
;	Atualiza a pontuação do utilizador, caso a pontuação corrente seja a mais 
;		elevada atualiza a pontução máxima
;	Recebe como entrada R1, o número de pontos a incrementar
;===============================================================================
RenderScore:	NOP
				PUSH	R2
				PUSH	R3
				ADD		M[Score], R1
				MOV		R2, 1
				MOV		R2, M[R2 + Score]
				MOV		R3, M[Score]
				CMP		R3, R2
				BR.NP	FIM_SCORE
				MOV		R2, 1
				MOV		M[R2 + Score], R3
	FIM_SCORE:	POP		R3
				POP		R2
				RET

;===============================================================================
;                                       escolher_modo: 
;		limita a escolhas do modo de jogo
;===============================================================================
escolher_modo:		NOP	
					PUSH	R1
					CALL    LimpaJanela
					MOV		M[MODO], R0
					CALL 	informacoes
	loop_escolha:	MOV		R1, M[MODO]
					CMP		R1, R0
					BR.Z	loop_escolha
					MOV		R1, 9155h
					MOV		M[PORTMASCARA_INT], R1
					CALL    LimpaJanela
					POP		R1
					RET
;===============================================================================
;                              informacoes: 
;		limita a escolhas do modo de jogo
;===============================================================================
informacoes:		NOP	
					PUSH	R1
					PUSH	Mensagem
					MOV		R1, 0000h
					PUSH	R1
					CALL	EscString
					POP		R1
					RET

;===============================================================================
;                                       InitInt: 
;===============================================================================
InitInt:    NOP		; TODO
        	MOV		R1, Pausa_Pac
			MOV 	M[TAB_INT0], R1
			MOV		R1, MoveDown_Pac
			MOV 	M[TAB_INT2], R1
        	MOV		R1, MoveLeft_Pac
            MOV 	M[TAB_INT4], R1
            MOV		R1, MoveRight_Pac
            MOV 	M[TAB_INT6], R1
            MOV		R1, MoveUp_Pac
			MOV 	M[TAB_INT8], R1
			MOV		R1, Modo_basico
            MOV 	M[TAB_INTA], R1
			MOV		R1, Modo_avancado
            MOV 	M[TAB_INTB], R1
			MOV		R1, Fim
            MOV 	M[TAB_INTC], R1
			MOV		R1, Temp_Pac
			MOV 	M[TAB_INTTemp], R1
			MOV		R1, M[Clock_Tic]
			MOV		M[TempValor], R1
			MOV		R1, 1
			MOV		M[TempControlo], R1
			MOV		R1, 0C00h
			MOV		M[PORTMASCARA_INT], R1
			RET

;===============================================================================
;                                Programa prinicipal
;
;	R2, serve 
;===============================================================================
inicio:     MOV     R1, SP_INICIAL
					MOV     SP, R1
					CALL	InitInt
					ENI
			

Reinicia:			NOP
					CALL	escolher_modo
					CALL	Reset_Labi
					CALL	RESET_VARIAVEIS
					CALL	RenderBichos
					;inicialização do ritmo dos monstros

NoUpDateDisplay:	NOP
			;rotina de segundo a segundo
					;velocidade
					DEC 	R5
					CMP 	R5,R0
					BR.NZ	MOVIM
					;faz mexer os monstros
					CALL	modo_de_jogo
					;==== Analise dos movimentos ====
	MOVIM:			MOV		R2, M[Mexe_PacMan]
					CMP		R2, 0002h
					CALL.Z	MoveDown_PacMan
					CMP		R2, 0004h
					CALL.Z	MoveLeft_PacMan
					CMP		R2, 0006h
					CALL.Z	MoveRight_PacMan
					CMP		R2, 0008h
					CALL.Z	MoveUp_PacMan
					MOV		M[Mexe_PacMan], R0
					CALL	PacMan_Comeu_Bicho?
					NOP
					MOV		R1, M[Update_Display]
					CMP		R1, R0
					JMP.Z	NoUpDateDisplay
					; só corre de segundo a segundo
					;faz update do display hexa
					CALL	UpDate_Display
					; imprime o ponto bonus
					CALL	BONUS_COMIDA
					;imprime o nr de vidas e pontos
					CALL	Print_Stats
					;imprime o tempo restante para comer o monstro nos lcd
					CALL	CountDown10
					MOV		R2, M[N_to_Display]
					;==== Escrita no LCD ====
					CALL	Escrita_no_LCD

									;==== Pausa com recurso a I0 ====

Em_Pausa:			MOV		R1, M[Pausa]
					CMP		R1, 1
					MOV		R1, 0001h
					MOV		M[PORTMASCARA_INT], R1
					BR.Z	Em_Pausa	;se no endereço estiver a um, ele continua em pausa
					MOV		R1, 9155h
					MOV		M[PORTMASCARA_INT], R1
					CMP   	R3,R0
      				JMP.P 	inicio
								
	 				JMP 	NoUpDateDisplay
			

Fim:        		NOP
					CALL    LimpaJanela
					MOV		R3,0611h;posicao na janela de jogo da string
					PUSH	Perdi
					PUSH	R3
					CALL	EscString
					;escrever A INFO na janela de texto
					MOV		R3, 0711h
					PUSH	INFO
					PUSH	R3
					CALL	EscString
					MOV		R1, 0000h
					MOV		M[PORTMASCARA_INT], R1
					MOV  	R3,1
					MOV   	R1,1
					MOV   	M[Pausa],R1
					CALL 	Em_Pausa
					BR     	Fim

;===============================================================================


