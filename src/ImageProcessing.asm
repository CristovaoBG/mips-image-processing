.data
	mostra: .word 0 #aponta o inicio da imagem

.data 0x10110000

imagem: .space 1048576 	# 1.048.576 = 0x 10 0000

.data 0x10210000
	kernel_Prewitt_X: .byte +1,0,-1,+1,0,-1,+1,0,-1
	kernel_Prewitt_Y: .byte -1,-1,-1,0,0,0,+1,+1,+1
	kernel_Sobel_X: .byte +1,0,-1,+2,0,-2,+1,0,-1
	kernel_Sobel_Y: .byte -1,-2,-1,0,0,0,+1,+2,+1
	kernel_LineDetectors_X: .byte +1,2,-1,+1,2,-1,+1,2,-1
	kernel_LineDetectors_Y: .byte -1,-1,-1,2,2,2,+1,+1,+1
	x: .byte 0
	msg_Inicial: .asciiz " \n digite o nome da imagem  que deseja editar (EX: nome.bmp)\n >"
	msg_Erro: .asciiz " Arquivo nao encontrado.\n Pressione ENTER para digitar novamente o nome da imagem"
	msg_ErroFmt: .asciiz "Este arquivo nao esta no formato correto (Assinatura  de arquivo invalida)\n Tente outro nome\n"
	menu_string: .asciiz " \nSelecione uma opção:\n 1. Borramento\n 2. Extração de Bordas\n 3. Limiar \n 4. Trocar imagem\n 5. Aplicar efeito atual\n 6. Exportar\n 7. RESETAR\n 0. Sair\nOpção: "
	msg_invalida: .asciiz " \n \n Opcao invalida.  Pressione ENTER para voltar ao menu!\n"
	msg_borra: .asciiz "escolha o grau de borramento (de 1 a 5)\n> "
	msg_ExBorda: .asciiz "escolha a mascara de extracao de borda:\n 1. Prewitt\n 2. Sobel\n 3. Detector de Linhas\n 0. Voltar ao menu anterior\n> "
	msg_ExBorda1: .asciiz "escolha a direcao:\n 1.Horizontal\n 2.Vertical\n 3. Ambas (distancia)\n> "
	msg_PB: .asciiz "\nescolha um limiar (de 0 a 255)\n> "
	msg_exportar: .asciiz "\ndigite o nome do arquivo a ser salvo (EX: nome.bmp)\n >"
	msg_fimS: .asciiz "\nimagem salva. Precione ENTER para continuar"
	msg_fimES:.asciiz "\narquivo gerado. Precione ENTER para continuar"
	msg_Processando: .asciiz "Prcessando...\n"
	filename: .space  64
	filename2: .space  64
	buff: .word 0
	cabecalho: .space 54
	
	NBytesL: .word 0		#numero de bytes por linha(largura em pixel *4)
	altura:.word 0		#altura da imagem
	original: .word 0
	
.text
inicio:
	li $v0, 4
	la $a0,msg_Inicial
	syscall   #imprim msg e prepara para ler nome do arquivo de importacao
	li $v0,8
	la $a0,filename
	li $a1,20
	syscall	  #le nome do arquivo de importacao
	#remove \n do final da string lida
	addiu $t7,$0,-1     
	busca0: #busca \n
		addiu $t7,$t7,1
		lbu $s0,filename($t7)
		bne $s0,'\n',busca0 
	sb $0,filename($t7) 
	#abre arquivo para leitura
	li $v0,13 
	la $a0,filename
	li $a1,0
	li $a2,0
	syscall 
	move $s6,$v0
	#erro se $v0 é menor que 0
	slti $t0, $v0, 0
	beq $t0, 0, importa # segue normalmente para importa se $v0 > 0
	li $v0, 4
	la $a0, msg_Erro
	syscall   # imprime mensage de erro
	li $v0,8 #??
	la $a0,x #??
	li $a1,1 #??
	syscall
	j inicio

importa:
	li $v0, 4
	la $a0, msg_Processando
	syscall   # imprime a mensagem
	
	#le cabecalho
	move $s0,$zero
	li $v0,14		# parametro de chamada de leitura de arquivo
	move $a0, $s6		# move o descritor para $a0
	la $a1, cabecalho	# le a assinatura para ver se realmente é um arquivo .bmp
	li $a2, 54		# tamanho máx de caracteres
	syscall			# devolve o número de caracteres lidos
	#verifica Assinatura
	lhu $t0,cabecalho
	beq $t0,0x4D42,continua_leiura1	#continua a leirura se formato for o correto
	li $v0, 4
	la $a0, msg_ErroFmt
	syscall   #imprime a mensagem de erro
	j inicio
	
	continua_leiura1:
		#le largura		
		li $t0,0
		li $t1,0
		lbu $t0,cabecalho+18
		lbu $t1,cabecalho+19
		sll $t1,$t1,8
		or $t0,$t0,$t1	
		mulou $t0,$t0,4
		sw $t0,NBytesL	#grava numero de bytes por linha(largura em pixel *4)
		#le altura
		li $t0,0
		li $t1,0
		lbu $t0,cabecalho+22
		lbu $t1,cabecalho+23
		sll $t1,$t1,8
		or $t0,$t0,$t1	
		sw $t0,altura
	leitura:
		li $v0,14		# parametro de chamada de leitura de arquivo
		move $a0, $s6		# move o descritor para $a0
		la $a1, buff		# endereco para armazenamento do s dados lidos
		li $a2, 3		# tamanho máx de caracteres
		syscall			# devolve o número de caracteres lidos
		beqz $v0,fimDeLeitura
		lw $t0,buff
		sw $t0,original($s0)
		addi $s0,$s0,4
		j leitura
	
	fimDeLeitura:
		subi $s0,$s0,4			#s0 guarda o numero de bytes
		
		li $v0,16		# fecha arquivo
		move $a0, $s6
		syscall
		
	jal flip_vertical
	
	#mostra imagem
		la $s1, original		# s1 = imagem orignal
		la $s3, mostra			# s3 = bitmapdisp
		move $s4, $zero			# i = 0

		loop:
			bge $s4, $s0, menu
			lw $s2, ($s1)
			sw $s2, ($s3)
			addi $s1, $s1, 4
			addi $s3, $s3, 4
			addi $s4, $s4, 4
			j loop
	

##########################################################

menu: 
	li $v0, 4
	la $a0, menu_string
	syscall   # imprime o menu
	
	li $v0, 5       
 	syscall	  # leitura da opcao
 	

 	sltiu $t1, $v0, 8
	
	bnez  $t1, continua
	li $v0, 4
	la $a0, msg_invalida
	syscall   # imprime a mensagem
	li $v0,8
	la $a0,x
	li $a1,1
	syscall
	j menu
		continua:
			beq $v0, 1, Borrar
			beq $v0, 2, ExBorda
			beq $v0, 3, Binarizacao
			beq $v0, 4, inicio
			beq $v0, 5, Salvar
			beq $v0, 6, Exportar
			beq $v0, 7, Resetar
			
			exit:
				li $v0, 10
				syscall


##########################################################################################

Borrar:	
	la $t0,original
	la $t8,imagem

	li $v0, 4
	la $a0, msg_borra
	syscall   # imprime perguntando grau de borramento

	li $v0,5	
	syscall
	move $s2,$v0		# grau de intepolacão
	
	li $v0,4
	la $a0, msg_Processando
	syscall   # imprime a mensagem

	lw $t3,NBytesL		#numero de bytes por linha
	mulo $t3,$s2,$t3	
	mulo $t2,$s2,4		
	add $s7,$t3,$t2		#constante a ser subitraida da posicão de memoria do pixel central da matriz, para se chegar ao inicio da matriz que sera interpolada
	mulo $s5,$s2,2
	addi $s5,$s5,1 		#numero de  colunas 
	mulo $s6,$s5,4		#numero de bytes dentro de uma linha da interpolacao

	subi $t0,$t0,4
	subi $t8,$t8,4
	li $s1,0
	loop2:	
		bge $s1,$s0,fim_loop2
		addiu $t0,$t0,4
		addiu $t8,$t8,4
		addi $s1,$s1,4
		li $s4,0		# quarda o valor final do pixel	
	
		# s3 inicio da interpolacão 
		sub $s3,$t0,$s7
		move $t7,$s3		# t7 quarda a posicao da linha lida
		li $t1,0		#conta as linhas interpoladas
		li $t2,0		# t2 conta os pixes da interpolaçao
		li $t4,0		# somatorio das intensidade de azuis
		li $t5,0		# somatorio das intensidade de verde
		li $t6,0		# somatorio das intensidade de vermelho
		li $t9,0		#conta as colunas interpoladas
		loop3:
			bge $t1,$s5,fim_matriz
			lbu $t3,($s3)
			add $t4,$t4,$t3
			addi $s3,$s3,1
		
			lbu $t3,($s3)
			add $t5,$t5,$t3
			addi $s3,$s3,1		
			
			lbu $t3,($s3)
			add $t6,$t6,$t3
			addi $s3,$s3,2	
					
			addi $t2,$t2,1
			addi $t9,$t9,4
			bge $t9,$s6,fim_de_linha
			j loop3
	fim_de_linha:
		addi $t1,$t1,1
		lw $s3,NBytesL
		add $t7,$t7,$s3	#vai para procima linha da matriz de interpolação
		move $s3,$t7
		li $t9,0
		j loop3
	fim_matriz:
		divu $t4,$t4,$t2
		move $s4,$t4
		divu $t5,$t5,$t2
		sll $t5,$t5,8
		divu $t6,$t6,$t2
		sll $t6,$t6,16
		or $s4,$s4,$t5
		or $s4,$s4,$t6
		sw $s4,($t8)
		j loop2
fim_loop2:
j print

#####################################################################
ExBorda:

	addi $sp,$sp,-40 #cria espacos para variaveis na pilha
	sw $a1,36($sp)
	sw $a0,32($sp)
	sw $ra,28($sp)
	sw $s6,24($sp)
	sw $s5,20($sp)
	sw $s4,16($sp)	
	sw $s3,12($sp)
	sw $s2,8($sp)
	sw $s1,4($sp)
	sw $s0,0($sp)	# empilha variaveis


	
	#la $s0,original		#imagem origem
	#la $s1,imagem		#imagem destino
	lw $s2,NBytesL		
	srl $s2,$s2,2		#numero de pixels(words) por linha
	lw $s3,altura		#numero de linhas
	#move $t0, $s6		# $s6 = tamanho da img em bytes
	repeteExBorda:	
	li $v0, 4
	la $a0, msg_ExBorda
	syscall   # imprime perguntando metodo: 1.Prewitt  2. Sobel  3.Detector de Linhas
	
	li $v0, 5       
 	syscall	  # leitura da opcao

	beq $v0,0,EndExBorda
	beq $v0,1,prewitt
	beq $v0,2,sobel
	beq $v0,3,detectorDeLinhas 	
	j repeteExBorda

	# carrega posicao de memoria do kernel desejado
	detectorDeLinhas:
		la $s4,kernel_Prewitt_X
		la $s5,kernel_Prewitt_Y
		li $s6, 1	# numero a ser feito a media
		j ExBordaCont
	prewitt:
		la $s4,kernel_Prewitt_X
		la $s5,kernel_Prewitt_Y
		li $s6, 3	# numero a ser feito a media
		j ExBordaCont
	sobel:	
		la $s4,kernel_Prewitt_X
		la $s5,kernel_Prewitt_Y
		li $s6, 4	# numero a ser feito a media
		j ExBordaCont
	ExBordaCont:

	#calcula posicao inicial do kernel (origem no centro do kernel)
	li $t7,1	#posicao x do kernel
	li $t8,1	#posicao y do kernel


	# loop principal (move grade ate que atinja o fim)
	loopExBorda:
		#calcula posicao na memoria usando os cursores
		mul $t9,$s2,$t8 # numPixLin*y
		add $t9,$t9,$t7	# +x
		sll $s7,$t9,2	# posicao em word
		la $a0,original($s7)	#endereco absoluto do pixel
		# calcula valor do pixel usando a grade X
		move $a1,$s4		#argumento a1 = endereco do kernel
		jal calculaPixel
			move $s0,$v0
			bgtz $v0, valorXzero	# valor da componente x eh zero se v0 eh negativo
			sub $s0,$zero,$v0		# $s0 = valor da componente X
			valorXzero:
		# calcula valor do pixel usando a grade Y
		move $a1,$s5		#argumento a1 = endereco do kernel
		jal calculaPixel	
			move $s1,$v0
			bgtz $v0, valorYzero	# valor da componente x eh zero se v0 eh negativo
			sub $s1,$zero,$v0		# $s0 = valor da componente X
			valorYzero:			
								
		# calcula como fica o byte e grava valor como pixel
		sll $s0,$s0,8		#posiciona como verde
		sll $s1,$s1,16		#posiciona como vermelho
		or $t9,$s0,$s1
		sw $t9,imagem($s7)	#salva pixel na posicao de imagem
		# incrementa posicao e verifica se terminou e volta a loopExBorda
		addi $t7,$t7,1			# incrementa cursor X
		#srl $t9,$s2,2			# numBytes/4 (numPixels)
		add $t9,$s2,-1			# $t9 = numPixels - 1
		blt $t7,$t9,loopExBorda		#salta se ainda tiverem elementos a direita
		li $t7,0		#zera X
		addi $t8,$t8,1		#incrementa Y
		add $t9,$s3,-1
		blt $t8,$t9,loopExBorda			#salta se ainda tem elementos abaixo
	EndExBorda:
	lw $s0,0($sp)	# desempilha variaveis
	lw $s1,4($sp)
	lw $s2,8($sp)	
	lw $s3,12($sp)
	lw $s4,16($sp)
	lw $s5,20($sp)
	lw $s6,24($sp)	
	lw $ra,28($sp)
	lw $a0,32($sp)
	lw $a1,36($sp)
	addi $sp,$sp,40	# libera espacos na pilha
	j print


	calculaPixel:	# $a0 = &pixel, $a1 = &kernel
		#la $s0,original		#imagem origem
		#la $s1,imagem		#imagem destino	
		li $t0, -1	#cursor da coluna
		li $t1, -1	#cursor da linha
		li $t2, 0	#acumulador (faz a media ao final)
		loopCalcPix:
			#calcula posicao do pixel na memoria
				# imgPos + 4*(cursCol + pixelsPorLinha*cursLin)
				mulu $t5,$s2,$t1 # pixelsPorLinha*cursLin
				add $t5,$t5,$t0	# + cursColEmWords
				sll $t5,$t5,2	# *4
				add $t5,$t5,$a0	# endereco na imagem
			#carrega valor do verde na posicao para registrador
				lhu $t5,0($t5)
				srl $t6,$t5,8
			#multiplica com o peso(a ser calculado tambem) e adiciona ao acumulador
				# &peso = &kernel+(cursCol+3*cursLin)
				mul $t5,$t1,3 	# 3*cursLin
				add $t5,$t5,$t0	# +cursCol
				add $t5,$t5,4	# coloca na origem da mascara
				add $t5,$t5,$a1 # +&kernel

				lb $t5,0($t5)	# $t5 <- peso
				mul $t5,$t5,$t6 # peso * verde
				add $t2,$t2,$t5 # adiciona resultado ao acumulador
			#incrementa cursores e volta ao loopSecundario, sai se acaba
			addi $t0,$t0,1	#incrementa 'x'
			bne $t0,2,loopCalcPix
			li $t0,-1
			addi $t1,$t1,1	#incrementa 'y'
			bne $t1,2,loopCalcPix
		#faz a normalizacao do valor
		div $t2,$s6
		#salva resultado em $v0
		mflo $v0
		jr $ra
#






#####################################################################
#preto e branco		
Binarizacao:
	
	li $v0, 4
	la $a0, msg_PB
	syscall   # imprime a mensagem

	li $v0,5	
	syscall
	move $s2,$v0		# grau de intepolacão

	li $v0, 4
	la $a0, msg_Processando
	syscall   # imprime a mensagem
	
	la $s1, original		# s1 = imagem
	la $s3, imagem			# s3 = bitmapdisp
	move $s4, $zero			# i = 0
	
	addi $s1,$s1,2			#verifica o byt verde
	loop4:
		
		
		bge $s4, $s0, print
		lbu $t0,($s1)		
		bgt $t0,$s2,branco
		j preto
		
			branco:
				li $t1,0x00FFFFFF
				j continuaPB
			
			preto:
				li $t1,0
				
		continuaPB:
		sw $t1, ($s3)
		addi $s1, $s1, 4
		addi $s3, $s3, 4
		addi $s4, $s4, 4
		j loop4
###########################################################
Salvar:
	la $s1, imagem			# s1 = imagem
	la $s3, original		# s3 = bitmapdisp
	move $s4, $zero			# i = 0

	loopS:
		bge $s4, $s0,fim_loops 
		lw $s2, ($s1)
		sw $s2, ($s3)
		addi $s1, $s1, 4
		addi $s3, $s3, 4
		addi $s4, $s4, 4
		j loopS
		
	fim_loops:
		li $v0, 4
		la $a0,msg_fimS
		syscall   # imprime a mensagem
		li $v0,8
		la $a0,x
		li $a1,1
		syscall
		j menu
#########################################################
Exportar:
	
	li $v0, 4
	la $a0,msg_exportar
	syscall   # imprime a mensagem
	li $v0,8
	la $a0,filename2
	li $a1,20
	syscall
	li $t0,'\n'
	addiu $t7,$0,-1     
	busca00: #busca \n
		addiu $t7,$t7,1
		lbu $t1,filename2($t7)
		bne $t1,$t0,busca00 
		sb $0,filename2($t7) #remove \n
	#abre arquivo para escrita
	li $v0,13 
	la $a0,filename2
	li $a1,1
	li $a2,0
	syscall 
	move $s6,$v0
	
	li $v0, 4
	la $a0, msg_Processando
	syscall   # imprime a mensagem
	escreve_cabecalho:
		li $v0,15		# parametro de chamada de escrita de arquivo
		move $a0, $s6		# move o descritor para $a0
		la $a1, cabecalho	# endereco contendo cabecalho
		li $a2,54		# tamanho máx de caracteres
		syscall	
		jal flip_vertical
	
	li $s1,0
	escreve:
		lbu  $t0,original($s1)
		addi $s1,$s1,1
		lbu $t1,original($s1)
		sll $t1,$t1,8
		or $t0,$t0,$t1
		addi $s1,$s1,1
		lbu $t1,original($s1)
		sll $t1,$t1,16	
		or $t0,$t0,$t1
		sw $t0,buff
		
		li $v0,15		# parametro de chamada de escrita de arquivo
		move $a0, $s6		# move o descritor para $a0
		la $a1, buff		# endereço para armazenamento dos dados lidos
		li $a2, 3		# tamanho máx de caracteres
		syscall			# devolve o número de caracteres lidos
		
		addi $s1,$s1,2
		bgt $s1,$s0,fimDeescrita
		j escreve
		
fimDeescrita:

	li $v0,16		# fecha arquivo
	move $a0, $s6
	syscall
	li $v0, 4
	la $a0,msg_fimES
	syscall   # imprime a mensagem
	li $v0,8
	la $a0,x
	li $a1,1
	syscall
	j menu	
	
##########################################################
Resetar:




	
##########################################################
flip_vertical:
	
		move $t5, $0		# j = 0
		lw $s1,NBytesL
		lw $s2,altura
		
		sub $s3,$s2,1
		mulo $s3,$s3,$s1	#s3 quarda a contante para se chegar ao primeiro pixel da ultima linha da imagem 
		
		div $s2,$s2,2	# meio da imagem
		div $s4,$s1,4	#s4 qurda a largura da imagem
		
		flip_vert:
		bge $t5, $s2, end_flip_vert

		la $t0, original		# x0, y0
		add $t1, $t0, $s3	# x0, y min;

		mulo $t6, $t5, $s1	# ajusta linha
		add $t0, $t0, $t6	# t0 = linha (j)

		sub $t1, $t1, $t6	# t1 = -linha (j)+512


		move $t4, $0		# i = 0
		swap:
			bge $t4, $s4, end_swap
			lw $t2, ($t0)		# swap
			lw $t3, ($t1)
			sw $t3, ($t0)
			sw $t2, ($t1)

			addi $t0, $t0, 4
			addi $t1, $t1, 4
		
			addiu $t4, $t4, 1	# i ++
			j swap
		end_swap:

			addi $t5, $t5, 1	# j++
			j flip_vert
		end_flip_vert:
		jr $ra

		

#################################################################
print:
	la $s1, imagem			# s1 = imagem
	la $s3, mostra			# s3 = bitmapdisp
	move $s4, $zero			# i = 0

	loopP:
		bge $s4, $s0, menu
		lw $s2, ($s1)
		sw $s2, ($s3)
		addi $s1, $s1, 4
		addi $s3, $s3, 4
		addi $s4, $s4, 4
		j loopP

