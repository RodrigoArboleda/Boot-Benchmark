;Rodrigo Cesar Arboleda - 2019
;NUSP - 10416722
jmp main					; inicia o programa

;;===============================================================================================
;;										variaveis
;;===============================================================================================
horaMem1: dw 0x0, 0x0, 0x0 	; armazena a hora do sistema
horaMem2: dw 0x0, 0x0, 0x0 	; armazena a hora do sistema(2)
s1: db "Inicio: ", 0x0 		; string de inicio
s2: db "Fim:    ", 0x0 		; string de fim
s3: db "Tempo:  ", 0x0 		; string de tempo decorrido


;;===============================================================================================
;;										  main
;;===============================================================================================
main:

	mov ax, s1 + 0x7c00 	; carrega o endereco da string
	call printString		; chama a rotina para printar uma string
	call hora				; mostra a hora atual do sistema
	
	call copiaHora			; copia a hora salva para outra regiao da memoria
	call benchmark			; chama a rotina para execultar o benchmark

	mov ax, s2 + 0x7c00		; carrega o endereco da string
	call printString		; chama a rotina para printar uma string
	call hora				; mostra a hora atual do sistema
	
	mov ax, s3 + 0x7c00 	; carrega o endereco da string
	call printString 		; chama a rotina para printar uma string
	call difHora			; calcula a diferenca das duas horas salvas na memoria

;;===============================================================================================
;;										  stop
;;===============================================================================================
stop:

	jmp stop				; pula para stop que no caso e a mesma linha, parando o programa


;;===============================================================================================
;;										benchmark
;;===============================================================================================
benchmark:

	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha
	push dx					; salva o registrador dx na pilha

	mov ax, 100				; carrega 100 no registrador ax

	mov cx, 0				; inicia o contador 1 do loop
loopContas1:
	
	inc cx					; incrementa o contador 1 do loop

	mov dx, 0				; inicia o contador 2 do loop
	loopContas2:			; loop 2
	
		inc dx				; incrementa o contador 2 do loop
		
		mov bx, 10			; carrega 10 no registador bx (define o denominador da divisao)
		call div			; chama a rotina para calculo de divisao
		call mulDez			; chama a rotina para calculo de multiplicacao

		cmp dx, 10000		; compara o contador 2
		jne loopContas2		; jump caso n tenha terminado o loop 2

	cmp cx, 10000			; compara o contador 1
	jne loopContas1			; jump caso n tenha terminado o loop 1

	pop dx					; recupera o registrador dx
	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax


	ret


;;===============================================================================================
;;									    mostra hora
;;===============================================================================================
hora:
	push ax					; salva o registrador ax na pilha
	push cx					; salva o registrador cx na pilha
	push dx					; salva o registrador dx na pilha

	mov ah, 02h				; carrega no registrador ah o codigo 02h (BIOS retorna a hora do sistema)
	int 1ah					; realiza uma interrupcao a bios

	call salvaHora			; salva a hora carrega na memoria

	xor ah, ah				; zera a parte alta do registrador ax (ah)
	mov al, ch 				; carrega as horas retornadas em ch para al
	call printNumHex		; chama a rotina para mostrar um numero

	mov al, 58				; carrega 58 em al (58 = ':' em ascii)
	call printChar			; chama a rotina para mostrar um caracter

	xor ah, ah				; zera a parte alta do registrador ax (ah)
	mov al, cl 				; carrega os minutos retornadas em cl para al
	call printNumHex		; chama a rotina para mostrar um numero

	mov al, 58				; carrega 58 em al (58 = ':' em ascii)
	call printChar			; chama a rotina para mostrar um numero

	xor ah, ah				; zera a parte alta do registrador ax (ah)
	mov al, dh 				; carrega os segundos retornadas em dh para al
	call printNumHex		; chama o procedimento para mostrar um numero

	mov al, 13 				; carrega 13 em al (13 = '\r' em ascii)
	call printChar			; chama a rotina para mostrar um caracter

	mov al, 10				; carrega 13 em al (10 = '\n' em ascii)
	call printChar			; chama a rotina para mostrar um caracter

	pop dx					; recupera o registrador dx
	pop cx					; recupera o registrador cx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;									     copia a hora
;;===============================================================================================
copiaHora:
	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha

	mov bx, horaMem2		; carrega o novo endereco
	mov cx, [horaMem1]		; carrega o valor das horas
	mov [bx], cx			; salva no novo endereco

	inc bx					; carrega o novo endereco
	mov cx, [horaMem1 + 1]	; carrega o valor dos minutos
	mov [bx], cx			; salva no novo endereco

	inc bx					; carrega o novo endereco
	mov cx, [horaMem1 + 2]	; carrega o valor dos segundoss
	mov [bx], cx			; salva no novo endereco

	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;									     salva a hora
;;===============================================================================================
salvaHora:
		
	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha
	push dx					; salva o registrador dx na pilha

	mov bx, horaMem1		; carrega o endereco de onde sera salva a hora

	xor ah, ah				; zera a parte alta do registrador ax
	
	mov al, ch 				; carrega na parte baixa do registrador al as horas
	mov [bx], ax 			; salva na memoria as horas

	mov al, cl 				; carrega na parte baixa do restrador al os minutos
	inc bx 					; carrega o proximo endereco
	mov [bx], ax 			; salva na memoria

	mov al, dh 				; carrega na parte baixa do restrador al os segundos
	inc bx 					; carrega o proximo endereco
	mov [bx], ax 			; salva na memoria

	pop dx					; recupera o registrador dx
	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;									   Diferenca de horas
;;===============================================================================================
difHora:

	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha
	push dx					; salva o registrador dx na pilha

	mov ax, [horaMem1]		; carrega o endereco de onde sera carrega a hora
	call carregaHoraSalva	; carrega a hora e retorna em cx (hora 1)
	mov dx, cx				; move para dx o conteudo carregado

	mov ax, [horaMem2]		; carrega o endereco de onde sera carrega a hora
	call carregaHoraSalva	; carrega a hora e retorna em cx

	sub dx, cx				; calcula a hora

	mov ax, [horaMem1 + 1]	; carrega o endereco de onde sera carrega a hora
	call carregaHoraSalva	; carrega a hora e retorna em cx
	mov bx, cx				; move para cx o conteudo carregado

	mov ax, [horaMem2 + 1]	; carrega o endereco de onde sera carrega a hora
	call carregaHoraSalva	; carrega a hora e retorna em cx
	
	sub bx, cx				; calcula os minutos

	cmp bx, 0x0				; compara os minutos calculados
	jge difHora2			; caso nao seja negativo pula as etapas a seguir
		add bx, 60			; soma 60 nos minutos
		sub dx, 1			; tira 1 das horas

difHora2:
	
	mov ax, dx				; carrega as horas em ax
	call printNum			; chama a rotina de printar um numero para mostrar as horas
	mov al, 58				; carrega 58 em al (58 = ':' em ascii)
	call printChar			; chama a rotina para mostrar um caracter


	mov ax, [horaMem1 + 2]	; carrega o endereco de onde sera carrega a hora
	call carregaHoraSalva	; carrega a hora e retorna em cx
	mov dx, cx				; move para dx o conteudo carregado

	mov ax, [horaMem2 + 2]	; carrega o endereco de onde sera carrega a hora
	call carregaHoraSalva	; carrega a hora e retorna em cx


	sub dx, cx				; calcula os segundos

	cmp dx, 0x0				; compara os segundos calculados
	jge difHora3			; caso nao seja negativo pula as etapas a seguir
		add dx, 60			; soma 60 nos segundos
		sub bx, 1			; tira 1 dos minutos

difHora3:	
	
	mov ax, bx 				; carrega os minutos em ax
	call printNum			; chama a rotina de printar um numero para mostrar as horas
	mov al, 58				; carrega 58 em al (58 = ':' em ascii)
	call printChar			; chama a rotina para mostrar um caracter


	mov ax, dx				; carrega os segundos em ax
	call printNum			; chama a rotina para mostrar um caracter

	pop dx					; recupera o registrador dx
	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;									 Carrega hora salva na memoria
;;===============================================================================================
carregaHoraSalva:

	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push dx					; salva o registrador dx na pilha

	mov bx, 16				; carrega 16 no registrador bx (define o mod e o div com 16)

	mov dx, ax				; salva o ax em dx
	call mod				; chama a rotina para realizar o mod de ax
	mov cx, ax				; move ax para cx

	mov ax, dx				; recupera valor salvo em dx
	call div				; chama a rotina para realizar a divisao de ax
	call mod 				; chama a rotina para realizar o mod de ax
	call mulDez				; chama a rotina para realizar a multiplicao de ax
	add cx, ax				; soma ax a cx

	pop dx					; recupera o registrador dx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;											ax mod(bx) e converte pra ascii
;;===============================================================================================
mod:
	
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha

loopMod:					; loop para calculo do mod
	mov cx, ax				; salva ax
	sub ax, bx				; realiza a subtracao de 16
	cmp ax, 0x0 			; compara com 0
	jl saiLoop 				; caso o numero tenha ficado negativo sai do loop
	jmp loopMod				; caso nao, continua o loop

saiLoop:

	mov ax, cx				; recupera o ultimo numero nao negativo do loop

	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	
	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;											   div (divide por bx, ax = ax/bx)
;;===============================================================================================
div:
	push bx					; salva o registrador bx na pilha
	push dx					; salva o registrador dx na pilha
	
	mov dx, 0				; zera o registrador dx (salva o resto da divisao) - ALERTA: caso nao zero esse registrador a operacao nao funciona 

	div bx					; realiza a divisao e armazena o resultado em ax (o resto esta em dx)

	pop dx					; recupera o registrador dx
	pop bx					; recupera o registrador bx

	ret						; retorna para onde foi chamado



;;===============================================================================================
;;									mulDez (multiplica por 10)
;;===============================================================================================
mulDez:
	push bx					; salva o registrador bx na pilha
	push dx					; salva o registrador dx na pilha

	mov bx, 10				; carrega em bx o valor 10 (valor em que ax sera multiplicado)
	mov dx, 0				; zera o registrador dx - ALERTA: caso nao zero esse registrador a operacao nao funciona 

	mul bx					; realiza a multiplicacao e armazena o resultado em ax

	pop dx					; recupera o registrador dx
	pop bx					; recupera o registrador bx

	ret						; retorna para onde foi chamado


;;===============================================================================================
;;									imprime numero Hexa(2 digitos)
;;===============================================================================================
printNumHex:

	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha

	mov cx, ax				; salva ax em bx

	mov bx, 16				; carrega 16 no registrador bx (define o mod e o div com 16)

	mov ax, cx				; carrega o numero salvo
	call div	 			; divide por 16 para tirar a unidade

	call mod 				; tira o mod de 16
	add ax, 48				; adiciona 48 (transforma em ascII)
	call printChar			; chama a rotina para mostrar um caracter

	mov ax, cx				; carrega o numero salvo
	call mod				; tira o mod de 16
	add ax, 48				; adiciona 48 (transforma em ascII)
	call printChar			; chama a rotina para mostrar um caracter

	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;									imprime numero (2 digitos)
;;===============================================================================================
printNum:

	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha
	push cx					; salva o registrador cx na pilha

	mov cx, ax				; salva ax em bx

	mov bx, 10				; carrega 10 no registrador bx (define o mod e o div com 10)

	mov ax, cx				; carrega o numero salvo
	call div				; divide por 10 para tirar a unidade

	call mod 				; tira o mod de 10
	add ax, 48				; adiciona 48 (transforma em ascII)
	call printChar			; chama a rotina para mostrar um caracter

	mov ax, cx				; carrega o numero salvo
	call mod				; tira o mod de 10
	add ax, 48				; adiciona 48 (transforma em ascII)
	call printChar			; chama a rotina para mostrar um caracter

	pop cx					; recupera o registrador cx
	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado


;;===============================================================================================
;;											Print Char
;;===============================================================================================
printChar:
	
	push ax					; salva o registrador ax na pilha

	mov ah, 0x0e			; carrega 0x0e em ah (interrupcao de escrita na tela)
	int 10h					; realiza uma interrupcao a BIOS

	pop ax					; recupera o registrador ax

	ret

;;===============================================================================================
;;											Print String
;;===============================================================================================
printString:
	
	push ax					; salva o registrador ax na pilha
	push bx					; salva o registrador bx na pilha

	mov bx, ax				; salva ax em bx

	mov al, [bx]			; carrega a primeira letra em al
	call printChar			; chama a rotina para mostrar um caracter

loopPrintString:
	inc bx					; carrega o endereco da proxima letra
	mov al, [bx]			; carreta a proma letra

	cmp al, 0x0				; verifica se a string acabou
	je printStringSai		; caso tenha acabado sai do loop
	
	call printChar			; chama a rotina para mostrar um caracter
	jmp loopPrintString		; retorna para o loop

printStringSai:

	pop bx					; recupera o registrador bx
	pop ax					; recupera o registrador ax

	ret 					; retorna para onde foi chamado

;;===============================================================================================
;;									completa com 0 o binario
;;===============================================================================================
	times 510-($-$$) db 0


;;===============================================================================================
;;									   assinatura do boot
;;===============================================================================================
	dw 0xaa55