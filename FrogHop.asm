;	Arquitetura e Organizacao de Computadores I
;	Trabalho do INTEL - 2020/2'
;	Anderson Caporale Anan - Cartao 00318259'
;====================================================================
;====================================================================
;
	.model		small
	.stack

	.data
CR		equ		0dh
LF		equ		0ah

;Variaveis
vetor 		db 'A','A','A','.','V','V','V',0
contPerdeu	db 0
varMover	db 0
varGravando db 0
numeroEscrever	db 0
varSairGrav		db 0
varLendo	db	0
numeroLido	db 0
varGanhou	db 0
contLoop	db 0
varMovInv	db 0
varErroLeitura db 0


FileNameSrc		db		256 dup (?)		; Nome do arquivo a ser lido
FileNameDst		db		256 dup (?)		; Nome do arquivo a ser escrito
FileHandle		dw		0				; Handler do arquivo destino
FileBuffer		db		10 dup (?)		; Buffer de leitura/escrita do arquivo
MAXSTRING		equ		200
String			db		MAXSTRING dup (?)		; Usado na funcao gets

; Frases:
msgLinha1		db  'Arquitetura e Organizacao de Computadores I', 0
msgLinha2		db 	'Trabalho do INTEL - 2020/2', 0
msgLinha3		db 	'Anderson Caporale Anan - Cartao 00318259', 0
msgMovimentos	db	'1-7 - Movimentacao de pecas.',CR, LF, 0
msgRecomecar	db	'Z - Recomecar o jogo.',CR, LF, 0
msgLer			db	'R - Ler arquivo de jogo.',CR, LF, 0
msgGravar		db	'G - Gravar arquivo de jogo.',CR, LF, 0
msgMovInvalido 	db 	'Movimento invalido', 0
msgGanhou  		db 	'Voce VENCEU o jogo!',0
msgPerdeu		db 	'Voce PERDEU o jogo!',0
msgNomeArquivo 	db 	'Entrar o nome do arquivo: ', 0
msgProxMov 		db	'N - Proximo Movimento',CR, LF, 0
msgOutrasTec 	db	'Outras Teclas - Encerra Leitura',CR, LF, 0
msgFimArq		db	'Chegou ao FIM do arquivo',0
msgEsc 			db	'ESC - encerrar a gravacao.',0
msgEsc2			db	'ESC - Voltar para o jogo.',0
msgEncGrav		db 	'Encerrar a gravacao (S/N)?',0
MolduraCima		db  '*--1--2--3--4--5--6--7--*',0
MolduraBaixo 	db  '*-----------*-----------*',0
MolduraMeio		db  'I', 0
msgNumeroLido	db	'Numero Lido: ', 0
msgMovimento1	db 	'[1]',0
msgMovimento2	db 	'[2]',0
msgMovimento3	db 	'[3]',0
msgMovimento4	db 	'[4]',0
msgMovimento5	db 	'[5]',0
msgMovimento6	db 	'[6]',0
msgMovimento7	db 	'[7]',0

MsgErroOpenFile		db	"Erro na abertura do arquivo.", CR, LF, 0
MsgErroCreateFile	db	"Erro na criacao do arquivo.", CR, LF, 0
MsgErroReadFile		db	"Erro na leitura do arquivo.", CR, LF, 0
MsgErroWriteFile	db	"Erro na escrita do arquivo.", CR, LF, 0
MsgCRLF				db	CR, LF, 0

	.code
	.startup
		
	call 	resetTela1				;Chama o reset de tela

	inicio:
	
	mov 	varGanhou,0				;Zera a variavel que indica que o jogo foi ganho
	call 	game					;Chama a exibição do vetor do jogo
	call	getKey					;Chama a função que pega a tecla
	call 	ganhou					;Chama a função que verifica se o jogo foi ganho
	
	cmp 	varGanhou,1				;Se o jogo foi ganho, volta pro inicio
	jz 		inicio					
	call 	perdeu					;Se não, verifica se o jogo foi perdido
	
	verificarGravacao:
	cmp		varGravando, 1			;Verifica se está no estado de gravação
	jz 		reset_tela_gravacao		
	jmp 	inicio

	reset_tela_gravacao:			;Chama a tela de gravação
	call	resetTela3
	
	gravarEntradas:
	mov 	varGravando,1			
	cmp 	varMovInv,1				;Verifica se houve alguma mensagem de erro
	jz		reset_game				;Se sim, não apaga
	call	resetTela3				;Se não houve erro, apaga a mensagem de erro
	jmp		continuar0

		reset_game:
		call	game					;Muda apenas o jogo, mas nao apaga a mensagem de erro

		continuar0:
		call 	getKeyGravacao			;Chama a função de gravar a tecla
		cmp 	varGravando, 1			;Verifica se ainda está gravando
		jz  	gravarEntradas			;Se sim, volta pro loop
		jmp 	verificarParar			;Se não está mais gravando, vai para verificar o encerramento da gravação 

		verificarParar:
		call 	confirmarParar			;Chama a tela de confirmar parada
		cmp 	varSairGrav, 1			;Verifica se é pra realmente sair
		jz 		sairGravacao
		jmp		reset_tela_gravacao			;Se não, volta para continuar gravando as entradas

		sairGravacao:
		mov 	varGravando,0			;Zera a variavel gravando
		mov     dl, '0'					;Finaliza o arquivo com '0'
		mov		bx,FileHandle	
		call	setChar
		call 	resetTela1				;Reseta a tela para o estado Jogar	
		mov		bx,FileHandle			
		call	fclose					;Fecha arquivo
		jmp 	inicio					;Volta para o estado Jogar

	.exit	0
	

;Função que coloca o cabeçalho na tela
cabecalho proc 	near
	mov		dh,0
	mov		dl,15
	call	SetCursor	
	lea		bx,msgLinha1
	call	printf_s
	
	mov		dh,1
	mov		dl,25
	call	SetCursor	
	lea		bx,msgLinha2
	call	printf_s

	mov		dh,2
	mov		dl,17
	call	SetCursor	
	lea		bx,msgLinha3
	call	printf_s

	ret
cabecalho endp

;Função que exibe os controles na tela
controles proc near
	mov		dh,20
	mov		dl,0
	call	SetCursor	
	lea		bx,msgMovimentos
	call	printf_s

	lea		bx,msgRecomecar
	call	printf_s

	lea		bx,msgLer
	call	printf_s

	lea		bx,msgGravar
	call	printf_s

	ret
controles endp

;Função que coloca o estado Jogando na tela
resetTela1 proc near
	call	clearScreen
	call	cabecalho
	call    game
	call 	contorno
	call 	controles
	ret
resetTela1 endp

;Função que apaga a parte de baixo da tela (instruções, comandos, ...)
resetTela2 proc near
	call	clearScreen
	call	cabecalho
	call    game
	call 	contorno
	ret
resetTela2 endp

;Função que coloca o estado Gravando na tela
resetTela3 proc near
	call	clearScreen
	call	cabecalho
	call    game
	call 	contorno

	mov		dh,22
	mov		dl,0
	call	SetCursor	
	lea		bx,msgMovimentos
	call	printf_s

	lea		bx,msgEsc
	call	printf_s

	ret
resetTela3 endp

;Função que coloca o estado Replay na tela
resetTela4 proc near
	call	clearScreen
	call	cabecalho
	call    game
	call 	contorno

	mov		dh,22
	mov		dl,0
	call	SetCursor	
	lea		bx,msgProxMov
	call	printf_s
	
	lea		bx,msgOutrasTec
	call	printf_s

	ret
resetTela4 endp

;Função que imprime que foi feito o movimento da peça 1
imprimir_movimento1 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento1
	call	printf_s
	ret
imprimir_movimento1 endp

;Função que imprime que foi feito o movimento da peça 2
imprimir_movimento2 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento2
	call	printf_s
	ret
imprimir_movimento2 endp

;Função que imprime que foi feito o movimento da peça 3
imprimir_movimento3 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento3
	call	printf_s
	ret
imprimir_movimento3 endp

;Função que imprime que foi feito o movimento da peça 4
imprimir_movimento4 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento4
	call	printf_s
	ret
imprimir_movimento4 endp

;Função que imprime que foi feito o movimento da peça 5
imprimir_movimento5 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento5
	call	printf_s
	ret
imprimir_movimento5 endp

;Função que imprime que foi feito o movimento da peça 6
imprimir_movimento6 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento6
	call	printf_s
	ret
imprimir_movimento6 endp

;Função que imprime que foi feito o movimento da peça 7
imprimir_movimento7 proc near
	mov		dh,14
	mov		dl,29
	call	SetCursor	
	lea		bx, msgNumeroLido
	call	printf_s
	lea		bx, msgMovimento7
	call	printf_s
	ret
imprimir_movimento7 endp

;Função que coloca o estado Encerrar Gravação na tela
confirmarParar proc near
	call	resetTela2
	mov		dh,20
	mov		dl,0
	call	SetCursor	
	lea		bx,msgEncGrav
	call	printf_s

	pegar_letra:
	mov		ah,7
	int		21H

	cmp 	AL, 'S'
	jz 		confirmarParar_sair
	cmp 	AL, 's'
	jz 		confirmarParar_sair
	cmp 	AL, 'N'
	jz		confirmarParar_continuar
	cmp 	AL, 'n'
	jz		confirmarParar_continuar
	jmp 	pegar_letra					;Fica no loop ate ser clicado S/s ou N/n

	confirmarParar_sair:
	mov 	varSairGrav, 1
	ret

	confirmarParar_continuar:
	mov 	varSairGrav, 0
	ret

confirmarParar endp

;Coloca o contorno do jogo na tela
contorno proc near
	mov		dh,8
	mov		dl,25
	call	SetCursor	
	lea		bx,MolduraCima
	call	printf_s

	mov		dh,9
	mov		dl,25
	call	SetCursor	
	lea		bx, MolduraMeio
	call	printf_s	

	mov		dh,9
	mov		dl,49
	call	SetCursor	
	lea		bx, MolduraMeio
	call	printf_s

	mov		dh,10
	mov		dl,25
	call	SetCursor	
	lea		bx, MolduraMeio
	call	printf_s

	mov		dh,10
	mov		dl,49
	call	SetCursor	
	lea		bx, MolduraMeio
	call	printf_s

	mov		dh,11
	mov		dl,25
	call	SetCursor	
	lea		bx, MolduraMeio
	call	printf_s

	mov		dh,11
	mov		dl,49
	call	SetCursor	
	lea		bx, MolduraMeio
	call	printf_s

	mov		dh,12
	mov		dl,25
	call	SetCursor	
	lea		bx,MolduraBaixo
	call	printf_s		

	ret
contorno endp

;Coloca o vetor do jogo na tela
game proc 	near
	mov		cl, 28
	mov		bp, 0

	loop_game:
	mov		dh, 10
	mov		dl, cl
	call	SetCursor	
	lea		bx, vetor[bp]
	call	printf
	add 	cl, 3
	inc 	bp
	cmp		bp, 7
	jnz		loop_game
	ret
	
game endp

;Função que coloca a mensagem de movimento invalido na tela
movimentoInvalido proc near
	
	inc 	contPerdeu	
	cmp 	varMover, 0				;Imprime a mensagem de movimento invalido, apenas se foi a função de mover que chamou
	jz 		movimentoInvalido_fim

	mov		varMovInv, 1
	mov		dh,15
	mov		dl,28
	call	SetCursor	
	lea		bx,msgMovInvalido
	call	printf_s

	movimentoInvalido_fim:
	ret
movimentoInvalido endp

;Função que pega as teclas digitadas
getKey	proc	near
		
	getKey_comparacoes:
	mov		ah,7
	int		21H
	mov		numeroLido, AL

	call	resetTela1

	mov 	varMover,1
	cmp 	numeroLido, '1'
	jz 		igual1
	cmp 	numeroLido, '2'
	jz 		igual2
	cmp 	numeroLido, '3'
	jz 		igual3
	cmp 	numeroLido, '4'
	jz 		igual4
	cmp 	numeroLido, '5'
	jz 		igual5
	cmp 	numeroLido, '6'
	jz 		igual6
	cmp 	numeroLido, '7'
	jz 		igual7
	cmp 	numeroLido, 'Z'
	jz 		recomecar
	cmp 	numeroLido, 'z'
	jz 		recomecar
	cmp 	numeroLido, 'G'
	jz 		gravar
	cmp 	numeroLido, 'g'
	jz 		gravar
	cmp 	numeroLido, 'R'
	jz 		ler
	cmp 	numeroLido, 'r'
	jz 		ler
	jmp 	getKey_comparacoes

	igual1:
	call 	verificar1
	ret

	igual2:
	call 	verificar2
	ret

	igual3:
	call 	verificar3
	ret

	igual4:
	call 	verificar4
	ret

	igual5:
	call 	verificar5
	ret

	igual6:
	call 	verificar6
	ret

	igual7:
	call 	verificar7
	ret

	recomecar:
	call	recomecarJogo
	ret
	
	gravar:
	mov 	varGravando,1
	call 	gravacao
	ret

	ler:
	call 	ler_arquivo
	ret

	getKey_fim:
	ret
getKey	endp

recomecarJogo	proc	near
	mov 	vetor, 'A'
	mov 	vetor+1, 'A'
	mov 	vetor+2, 'A'
	mov 	vetor+3, '.'
	mov 	vetor+4, 'V'
	mov 	vetor+5, 'V'
	mov 	vetor+6, 'V'
	call 	resetTela1
	ret
recomecarJogo	endp

;Função que grava as teclas digitadas
getKeyGravacao	proc	near
	mov		ah,7
	int		21H

	mov		varMover,1
	mov 	numeroEscrever, al
	cmp 	AL, '1'
	jz 		gravacao_igual1
	cmp 	AL, '2'
	jz	 	gravacao_igual2
	cmp 	AL, '3'
	jz 		gravacao_igual3
	cmp		AL, '4'
	jz 		gravacao_igual4
	cmp 	AL, '5'
	jz 		gravacao_igual5
	cmp 	AL, '6'
	jz 		gravacao_igual6
	cmp 	AL, '7'
	jz 		gravacao_igual7
	cmp 	AL, 27					;Tecla esc
	jz 		gravacao_encerrar
	ret

	gravacao_igual1:
	call 	verificar1
	jmp 	gravacao_fim

	gravacao_igual2:
	call 	verificar2
	jmp 	gravacao_fim

	gravacao_igual3:
	call 	verificar3
	jmp 	gravacao_fim

	gravacao_igual4:
	call 	verificar4
	jmp 	gravacao_fim

	gravacao_igual5:
	call 	verificar5
	jmp 	gravacao_fim

	gravacao_igual6:
	call 	verificar6
	jmp 	gravacao_fim

	gravacao_igual7:
	call 	verificar7
	jmp 	gravacao_fim

	gravacao_encerrar:
	mov 	varGravando,0
	ret
	
	gravacao_fim:
	mov		bx,FileHandle
	mov     dl, numeroEscrever
	call	setChar
	jnc		getKeyGravacao_fim
	mov		bx,FileHandle		
	call	fclose				;Fecha o arquivo se houve erro na escrita
	
	getKeyGravacao_fim:
	ret
getKeyGravacao	endp

;Função que verifica se é possível mover na posição 1
verificar1	proc	near
	cmp 	vetor, 'A'
	jz 		verificar1_continuaA
	cmp 	vetor, 'V'
	jz 		verificar1_continuaV
	jmp 	verificar1_erro

	verificar1_continuaA:
	cmp 	vetor+1, 'A'
	jz 		verificar1_erro
	cmp 	vetor+1, '.'
	jz 		verificar1_mover
	cmp 	vetor+2, '.'
	jz 		verificar1_pular
	jmp 	verificar1_erro

	verificar1_continuaV:	
	jmp 	verificar1_erro

	verificar1_mover:
	cmp 	varMover, 0
	jz 		verificar1_fim
	mov 	vetor, '.'
	mov 	vetor+1, 'A'
	mov		varMovInv,0
	ret

	verificar1_pular:
	cmp 	varMover, 0
	jz 		verificar1_fim
	mov 	vetor, '.'
	mov 	vetor+2, 'A'
	mov		varMovInv,0
	ret

	verificar1_erro:
	call 	movimentoInvalido
	
	verificar1_fim:
	ret

verificar1	endp

;Função que verifica se é possível mover na posição 2
verificar2	proc	near
	cmp 	vetor+1, 'A'
	jz 		verificar2_continuaA
	cmp 	vetor+1, 'V'
	jz 		verificar2_continuaV
	jmp 	verificar2_erro	
	
	verificar2_continuaA:
	cmp 	vetor+2, 'A'
	jz 		verificar2_erro
	cmp 	vetor+2, '.'
	jz 		verificar2_moverA
	cmp 	vetor+3, '.'
	jz 		verificar2_pular
	jmp 	verificar2_erro

	verificar2_continuaV:
	cmp 	vetor, '.'
	jz 		verificar2_moverV
	jmp 	verificar2_erro

	verificar2_moverA:
	cmp 	varMover, 0
	jz 		verificar2_fim
	mov 	vetor+1, '.'
	mov 	vetor+2, 'A'
	mov		varMovInv,0
	ret

	verificar2_moverV:
	cmp 	varMover, 0
	jz 		verificar2_fim
	mov 	vetor+1, '.'
	mov 	vetor, 'V'	
	mov		varMovInv,0
	ret

	verificar2_pular:
	cmp 	varMover, 0
	jz 		verificar2_fim
	mov 	vetor+1, '.'
	mov 	vetor+3, 'A'
	mov		varMovInv,0
	ret

	verificar2_erro:
	call 	movimentoInvalido

	verificar2_fim:
	ret

verificar2	endp

;Função que verifica se é possível mover na posição 3
verificar3	proc	near	
	cmp 	vetor+2, 'A'
	jz 		verificar3_continuaA
	cmp 	vetor+2, 'V'
	jz 		verificar3_continuaV
	jmp 	verificar3_erro
		
	verificar3_continuaA:
	cmp 	vetor+3, 'A'
	jz 		verificar2_erro
	cmp 	vetor+3, '.'
	jz		verificar3_moverA
	cmp 	vetor+4, '.'
	jz 		verificar3_pularA
	jmp 	verificar3_erro

	verificar3_continuaV:
	cmp 	vetor+1, 'V'
	jz 		verificar3_erro
	cmp 	vetor+1, '.'
	jz 		verificar3_moverV
	cmp 	vetor, '.'
	jz 		verificar3_pularV
	jmp 	verificar3_erro

	verificar3_moverA:
	cmp 	varMover, 0
	jz 		verificar3_fim
	mov 	vetor+2, '.'
	mov 	vetor+3, 'A'
	mov		varMovInv,0
	ret

	verificar3_moverV:
	cmp 	varMover, 0
	jz 		verificar3_fim
	mov 	vetor+2, '.'
	mov 	vetor+1, 'V'	
	mov		varMovInv,0
	ret

	verificar3_pularA:
	cmp 	varMover, 0
	jz 		verificar3_fim
	mov 	vetor+2, '.'
	mov 	vetor+4, 'A'
	mov		varMovInv,0
	ret

	verificar3_pularV:
	cmp 	varMover, 0
	jz 		verificar3_fim
	mov 	vetor+2, '.'
	mov 	vetor, 'V'
	mov		varMovInv,0
	ret

	verificar3_erro:
	call 	movimentoInvalido

	verificar3_fim:
	ret

verificar3	endp

;Função que verifica se é possível mover na posição 4
verificar4	proc	near
	cmp 	vetor+3, 'A'
	jz 		verificar4_continuaA
	cmp 	vetor+3, 'V'
	jz 		verificar4_continuaV
	jmp		verificar3_erro

	verificar4_continuaA:
	cmp 	vetor+4, 'A'
	jz 		verificar3_erro
	cmp 	vetor+4, '.'
	jz 		verificar4_moverA
	cmp 	vetor+5, '.'
	jz 		verificar4_pularA
	jmp 	verificar4_erro

	verificar4_continuaV:
	cmp 	vetor+2, 'V'
	jz 		verificar4_erro
	cmp 	vetor+2, '.'
	jz 		verificar4_moverV
	cmp 	vetor+1, '.'
	jz 		verificar4_pularV
	jmp 	verificar4_erro

	verificar4_moverA:
	cmp 	varMover, 0
	jz 		verificar4_fim
	mov 	vetor+3, '.'
	mov 	vetor+4, 'A'
	mov		varMovInv,0
	ret

	verificar4_moverV:
	cmp 	varMover, 0
	jz 		verificar4_fim
	mov 	vetor+3, '.'
	mov 	vetor+2, 'V'
	ret

	verificar4_pularA:
	cmp 	varMover, 0
	jz 		verificar4_fim
	mov 	vetor+3, '.'
	mov 	vetor+5, 'A'
	mov		varMovInv,0
	ret

	verificar4_pularV:
	cmp 	varMover, 0
	jz 		verificar4_fim
	mov 	vetor+3, '.'
	mov 	vetor+1, 'V'
	mov		varMovInv,0
	ret

	verificar4_erro:
	call	movimentoInvalido

	verificar4_fim:
	ret

verificar4	endp

;Função que verifica se é possível mover na posição 5
verificar5 proc near
	cmp		vetor+4, 'A'
	jz 		verificar5_continuaA
	cmp 	vetor+4, 'V'
	jz 		verificar5_continuaV
	jmp 	verificar4_erro

	verificar5_continuaA:
	cmp 	vetor+5, 'A'
	jz 		verificar4_erro
	cmp 	vetor+5, '.'
	jz 		verificar5_moverA
	cmp 	vetor+6, '.'
	jz 		verificar5_pularA
	jmp 	verificar5_erro

	verificar5_continuaV:
	cmp 	vetor+3, 'V'
	jz 		verificar5_erro
	cmp 	vetor+3, '.'
	jz 		verificar5_moverV
	cmp 	vetor+2, '.'
	jz 		verificar5_pularV
	jmp 	verificar5_erro

	verificar5_moverA:
	cmp 	varMover, 0
	jz 		verificar5_fim
	mov 	vetor+4, '.'
	mov 	vetor+5, 'A'
	mov		varMovInv,0
	ret

	verificar5_moverV:
	cmp 	varMover, 0
	jz 		verificar5_fim
	mov 	vetor+4, '.'
	mov 	vetor+3, 'V'
	ret

	verificar5_pularA:
	cmp 	varMover, 0
	jz 		verificar5_fim
	mov 	vetor+4, '.'
	mov 	vetor+6, 'A'
	mov		varMovInv,0
	ret

	verificar5_pularV:
	cmp 	varMover, 0
	jz 		verificar5_fim
	mov 	vetor+4, '.'
	mov 	vetor+2, 'V'
	mov		varMovInv,0
	ret

	verificar5_erro:
	call 	movimentoInvalido

	verificar5_fim:
	ret

verificar5 endp

;Função que verifica se é possível mover na posição 6
verificar6 proc near
	cmp 	vetor+5, 'A'
	jz 		verificar6_continuaA
	cmp 	vetor+5, 'V'
	jz 		verificar6_continuaV
	jmp 	verificar2_erro	
	
	verificar6_continuaA:
	cmp 	vetor+6, '.'
	jz 		verificar6_moverA
	jmp 	verificar6_erro

	verificar6_continuaV:
	cmp 	vetor+4, 'V'
	jz 		verificar6_erro
	cmp 	vetor+4, '.'
	jz 		verificar6_moverV
	cmp 	vetor+3, '.'
	jz 		verificar6_pular
	jmp 	verificar6_erro

	verificar6_moverA:
	cmp 	varMover, 0
	jz 		verificar6_fim
	mov 	vetor+5, '.'
	mov 	vetor+6, 'A'
	mov		varMovInv,0
	ret

	verificar6_moverV:
	cmp 	varMover, 0
	jz 		verificar6_fim
	mov 	vetor+5, '.'
	mov 	vetor+4, 'V'	
	mov		varMovInv,0
	ret

	verificar6_pular:
	cmp 	varMover, 0
	jz 		verificar6_fim
	mov 	vetor+5, '.'
	mov 	vetor+3, 'V'
	mov		varMovInv,0
	ret

	verificar6_erro:
	call 	movimentoInvalido

	verificar6_fim:
	ret

verificar6 endp

;Função que verifica se é possível mover na posição 7
verificar7 proc near
	cmp 	vetor+6, 'A'
	jz 		verificar7_continuaA
	cmp 	vetor+6, 'V'
	jz		verificar7_continuaV
	jmp 	verificar7_erro

	verificar7_continuaA:
	jmp 	verificar7_erro

	verificar7_continuaV:		
	cmp 	vetor+5, 'V'
	jz 		verificar7_erro
	cmp 	vetor+5, '.'
	jz 		verificar7_mover
	cmp		vetor+4, '.'
	jz 		verificar7_pular
	jmp 	verificar7_erro

	verificar7_mover:
	cmp 	varMover, 0
	jz 		verificar7_fim
	mov 	vetor+6, '.'
	mov 	vetor+5, 'V'
	mov		varMovInv,0
	ret

	verificar7_pular:
	cmp 	varMover, 0
	jz 		verificar7_fim
	mov 	vetor+6, '.'
	mov 	vetor+4, 'V'
	mov		varMovInv,0
	ret

	verificar7_erro:
	call	movimentoInvalido

	verificar7_fim:
	ret

verificar7 endp

;Função que grava o jogo
gravacao proc near
	call 	resetTela2
	mov		dh,23
	mov		dl,0
	call	SetCursor
	call 	GetFileNameDst

	lea		dx,FileNameDst
	call 	fcreate
	mov		FileHandle,bx

	mov 	bp,0		;Zera o indice

	escrever:
	mov     dl, vetor[bp]	;Grava a situação atual do jogo no arquivo
	mov		bx,FileHandle
	call	setChar
	inc 	bp
	cmp 	bp,7
	jnz 	escrever

	mov     dl, CR
	call	setChar
	mov     dl, LF
	call	setChar

	ret

gravacao endp

;Função que le os movimentos do arquivo
ler_arquivo proc near
	mov		contLoop, 0
	mov		varErroLeitura, 0
	call 	resetTela2
	mov		dh,21
	mov		dl,0
	call	SetCursor
	call 	GetFileNameDst

	lea		dx,FileNameDst
	call	fopen
	mov		FileHandle,bx
	jnc		ler_jogo
	lea		bx, MsgErroOpenFile		;Erro ao abrir arquivo
	call	printf_s

	voltar_erro:
	lea		bx, msgEsc2
	call	printf_s
	jmp 	ler_esc

	ler_jogo:						;Salva as posições do jogo conforme o arquivo
	mov		bx,FileHandle
	call	getChar
	mov		bp, 0
	call 	salvar_jogo_lido
	call	getChar
	mov		bp, 1
	call 	salvar_jogo_lido
	call	getChar
	mov		bp, 2
	call 	salvar_jogo_lido
	call	getChar
	mov		bp, 3
	call 	salvar_jogo_lido
	call	getChar
	mov		bp, 4
	call 	salvar_jogo_lido
	call	getChar
	mov		bp, 5
	call 	salvar_jogo_lido
	call	getChar
	mov		bp, 6
	call 	salvar_jogo_lido
	cmp		varErroLeitura, 1
	jz		erro_leitura_2		
	call	getChar					;Pula o CR e LF
	call	getChar
	jmp		Continuar1

	Continuar1:
	call 	resetTela4
	mov		ah,7		;getkey
	int		21H
	cmp 	AL, 'N'			
	jz 		Continuar2
	cmp 	AL, 'n'
	jz 		Continuar2
	call 	resetTela1		;Qualquer tecla diferente de N/n retorna para o estado Jogando
	ret
	
	Continuar2:
	call 	resetTela4
	mov		bx,FileHandle
	call	getChar
	jnc		Continua3
	lea		bx, MsgErroReadFile
	call	printf_s
	mov		bx,FileHandle
	call	fclose
	jmp 	erro_leitura

	Continua3:
	cmp		dl,'0'
	jz		TerminouArquivo
	cmp 	dl, '1'
	jz 		igual1_2
	cmp 	dl, '2'
	jz 		igual2_2
	cmp 	dl, '3'
	jz 		igual3_2
	cmp 	dl, '4'
	jz 		igual4_2
	cmp 	dl, '5'
	jz 		igual5_2
	cmp 	dl, '6'
	jz 		igual6_2
	cmp 	dl, '7'
	jz 		igual7_2
	jmp 	erro_leitura
	
	continuar2_2:				;Ponte para continuar2 
	jmp 	continuar2

	erro_leitura_2:				;Ponte para erro_leitura 
	jmp 	erro_leitura

	igual1_2:
	call 	verificar1
	call 	imprimir_movimento1
	jmp 	ler_proximo
		
	igual2_2:
	call 	verificar2
	call 	imprimir_movimento2
	jmp 	ler_proximo
	
	igual3_2:
	call 	verificar3
	call 	imprimir_movimento3
	jmp 	ler_proximo
	
	igual4_2:
	call 	verificar4
	call 	imprimir_movimento4
	jmp 	ler_proximo
	
	igual5_2:
	call 	verificar5
	call	imprimir_movimento5
	jmp		ler_proximo
	
	igual6_2:
	call 	verificar6
	call 	imprimir_movimento6
	jmp 	ler_proximo
	
	igual7_2:
	call 	verificar7
	call 	imprimir_movimento7

	ler_proximo:
	call	game
	mov		ah,7
	int		21H	
	cmp 	AL, 'N'
	jz 		continuar2_2
	cmp 	AL, 'n'
	jz	 	continuar2_2
	call 	resetTela1
	ret

	TerminouArquivo:
	call 	resetTela2
	mov		dh,22
	mov		dl,0
	call	SetCursor	
	lea		bx,msgFimArq
	call	printf_s

	mov		dh,23
	mov		dl,0
	call	SetCursor	
	lea		bx,msgEsc2
	call	printf_s

	mov		bx,FileHandle	
	call	fclose			;Fecha o arquivo

	ler_esc:
	mov		ah,7
	int		21H
	cmp 	AL, 27
	jz 		ler_arquivo_fim
	jmp 	ler_esc

	erro_leitura:
	call	resetTela2
	mov		dh,22
	mov		dl,0
	call	SetCursor	
	lea		bx,MsgErroReadFile
	call	printf_s
	lea		bx,msgEsc2
	call	printf_s
	jmp		ler_esc

	ler_arquivo_fim:
	call 	resetTela1
	ret

ler_arquivo endp

;Função que pega a situação do jogo no arquivo e coloca no programa
salvar_jogo_lido proc near

	cmp 	dl, 'A'
	jz 		salvar_posicao
	cmp 	dl, 'V'
	jz 		salvar_posicao
	cmp 	dl, '.'
	jz 		salvar_posicao
	mov		varErroLeitura, 1
	ret

	salvar_posicao:
	mov		vetor[bp], dl
	ret

salvar_jogo_lido endp

;Função que verifica se houve vitória
ganhou proc near
	cmp 	vetor, 'V'
	jnz 	ganhar_fim
	cmp 	vetor+1, 'V'
	jnz 	ganhar_fim
	cmp 	vetor+2, 'V'
	jnz 	ganhar_fim
	cmp 	vetor+3, '.'
	jnz 	ganhar_fim
	cmp 	vetor+4, 'A'
	jnz 	ganhar_fim
	cmp 	vetor+5, 'A'
	jnz 	ganhar_fim
	cmp 	vetor+6, 'A'
	jnz 	ganhar_fim

	call 	resetTela2

	mov		dh,20
	mov		dl,28
	call	SetCursor	
	lea		bx,msgGanhou
	call	printf_s
	mov		dh,21
	mov		dl,25
	call	SetCursor	
	lea		bx,msgEsc2
	call	printf_s
	mov 	varGanhou,1

	ganhou_ler_esc:
	mov		ah,7
	int		21H
	cmp 	AL, 27
	jz 		ganhou_limpar_tela
	jmp 	perdeu_ler_esc

	ganhou_limpar_tela:
	call 	resetTela1

	ganhar_fim:
	ret

ganhou endp

;Função que verifica se houve derrota
perdeu proc near
	mov 	contPerdeu, 0	;Zera o contador de perdeu
	mov 	varMover,0		;Não move as peças nos testes

	call 	verificar1
	call 	verificar2
	call 	verificar3
	call 	verificar4
	call 	verificar5
	call 	verificar6
	call 	verificar7

	cmp 	contPerdeu, 7	;Se todas as opções de movimento deram erro, então perdeu o jogo
	jnz 	perdeu_retorno	

	perdeu_fim:
	call	resetTela2
	mov		dh,20
	mov		dl,28
	call	SetCursor	
	lea		bx, msgPerdeu
	call	printf_s

	mov		dh,21
	mov		dl,25
	call	SetCursor	
	lea		bx,msgEsc2
	call	printf_s

	perdeu_ler_esc:
	mov		ah,7
	int		21H
	cmp 	AL, 27
	jz 		perdeu_limpar_tela
	jmp 	perdeu_ler_esc

	perdeu_limpar_tela:
	call 	resetTela1

	perdeu_retorno:
	ret

perdeu endp


;;---------------
;;FUNÇÕES PRONTAS
;;---------------

;--------------------------------------------------------------------
;Função: Limpa a tela e coloca no formato texto 80x25
;--------------------------------------------------------------------
clearScreen	proc	near
	mov	ah,0	; Seta modo da tela
	mov	al,7	; Text mode, monochrome, 80x25.
	int	10h
	ret
clearScreen	endp

;--------------------------------------------------------------------
;Função Escrever um string na tela
;		printf_s(char *s -> BX)
;--------------------------------------------------------------------
printf_s	proc	near
	mov		dl,[bx]
	cmp		dl,0
	je		ps_1

	push	bx
	mov		ah,2
	int		21H
	pop		bx

	inc		bx		
	jmp		printf_s
		
ps_1:
	ret
printf_s	endp

printf	proc	near
	mov		dl,[bx]
	push	bx
	mov		ah,2
	int		21H
	pop		bx
	ret	
printf	endp

;--------------------------------------------------------------------
;Função: posiciona o cursor
;	mov		dh,linha
;	mov		dl,coluna
;	call	SetCursor
;MS-DOS
;	AH = 02h
;	BH = page number
;		0-3 in modes 2&3
;		0-7 in modes 0&1
;		0 in graphics modes
;	DH = row (00h is top)
;	DL = column (00h is left)
;--------------------------------------------------------------------
SetCursor	proc	near
	mov	ah,2
	mov	bh,0
	int	10h
	ret
SetCursor	endp


;Entra: BX -> file handle
;       dl -> caractere
;Sai:   AX -> numero de caracteres escritos
;		CF -> "0" se escrita ok
;--------------------------------------------------------------------
setChar	proc	near
	mov		ah,40h
	mov		cx,1
	mov		FileBuffer,dl
	lea		dx,FileBuffer
	int		21h
	ret
setChar	endp

;--------------------------------------------------------------------
;Funcao Pede o nome do arquivo de destino salva-o em FileNameDst
;--------------------------------------------------------------------
GetFileNameDst	proc	near
	;printf("Nome do arquivo destino: ");
	lea		bx, msgNomeArquivo
	call	printf_s
	
	;gets(FileNameDst);
	lea		bx, FileNameDst
	call	gets
	
	;printf("\r\n")
	lea		bx, MsgCRLF
	call	printf_s
	
	ret
GetFileNameDst	endp


;--------------------------------------------------------------------
;Funcao Le um string do teclado e coloca no buffer apontado por BX
;		gets(char *s -> bx)
;--------------------------------------------------------------------
gets	proc	near
	push	bx

	mov		ah,0ah						; L� uma linha do teclado
	lea		dx,String
	mov		byte ptr String, MAXSTRING-4	; 2 caracteres no inicio e um eventual CR LF no final
	int		21h

	lea		si,String+2					; Copia do buffer de teclado para o FileName
	pop		di
	mov		cl,String+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	mov		byte ptr es:[di],0			; Coloca marca de fim de string
	ret
gets	endp


;--------------------------------------------------------------------
;Fun��o	Le um caractere do arquivo identificado pelo HANLDE BX
;		getChar(handle->BX)
;Entra: BX -> file handle
;Sai:   dl -> caractere
;		AX -> numero de caracteres lidos
;		CF -> "0" se leitura ok
;--------------------------------------------------------------------
getChar	proc	near
	mov		ah,3fh
	mov		cx,1
	lea		dx,FileBuffer
	int		21h
	mov		dl,FileBuffer
	ret
getChar	endp


;--------------------------------------------------------------------
;Fun��o	Abre o arquivo cujo nome est� no string apontado por DX
;		boolean fopen(char *FileName -> DX)
;Entra: DX -> ponteiro para o string com o nome do arquivo
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
;--------------------------------------------------------------------
fopen	proc	near
	mov		al,0
	mov		ah,3dh
	int		21h
	mov		bx,ax
	ret
fopen	endp


;Fun��o Cria o arquivo cujo nome est� no string apontado por DX
;		boolean fcreate(char *FileName -> DX)
;Sai:   BX -> handle do arquivo
;       CF -> 0, se OK
fcreate	proc	near
	mov		cx,0
	mov		ah,3ch
	int		21h
	mov		bx,ax
	ret
fcreate	endp

fclose	proc	near
	mov		ah,3eh
	int		21h
	ret
fclose	endp

;--------------------------------------------------------------------
		end
;--------------------------------------------------------------------