.data

	image_name:   	.asciz "lenaeye.raw"	# nome da imagem a ser carregada
	address: 	.word   0x10040000			# endereco do bitmap display na memoria	
	address2:	.word   0x10043F00			#1 pra baixo = +100, 1 pra direita, � +4
	#0x10043F00 = canto inferior esquerdo
	#0x10043FFC = canto inferior direito
	#0x10040000 = canto superior esquerdo
	#0x100400FC = canto superior direito
	buffer:		.word   0					# configuracao default do RARS
	size:		.word	4096				# numero de pixels da imagem

	str_menu:	.asciz "Defina o n�mero da op��o desejada:\n\n1- Obt�m Ponto\n2- Desenha ponto\n3- Desenha ret�ngulo com preenchimento\n4- Desenha ret�ngulo sem preenchimento\n5- Converte para o negativo da imagem\n6- Converte imagem para tons de vermelho\n7- Carrega imagem\n8- Encerra\n\n"									 

	str_coord_x:	.asciz "Digite o valor da coordenada X: "	
	str_coord_y: 	.asciz "Digite o valor da coordenada Y: "
	str_pega_R:	.asciz "Digite o valor da componente R: "
	str_pega_G:	.asciz "Digite o valor da componente G: "
	str_pega_B:	.asciz "Digite o valor da componente B: "

.text


menu:

	li a6, 0		# a6 resetado, onde fica a op��o do usu�rio

	li a7, 4
  	la a0, str_menu		# printa o menu
  	ecall
  	
     	li a7, 5		# da scanf
  	ecall
  		
  	mv a6, a0		# botamos a6
	li a2, 1		# compara��o para branch de fun��o 
	
	#fun��o 1 aqui
	
	
	li a2, 2
	beq a6, a2, desenha_ponto
	
	#sucessivamente se incrementa a2, compara com a sua fun��o respectiva
	
	li a2, 7
	beq a6, a2, carrega_imagem
	
	li a2, 8
	beq a6, a2, fim
	

carrega_imagem: 
		
 	# define par�metros e chama a fun��o para carregar a imagem
	la a0, image_name
	lw a1, address
	la a2, buffer
	lw a3, size
	jal load_image
	
	b menu
	
desenha_ponto:
	
	# parametro usado para fazer o ponto
	lw a4, address2		
	jal draw_point		#ta fazendo o ponto vers�o 1.0 � nois
	
	b menu
  	
 fim:
 
  	# FIM
	# defini��o da chamada de sistema para encerrar programa	
	# par�metros da chamada de sistema: a7=10
	li a7, 10		
	ecall
	
	#---------------------------FINAL DA MAIN---------------------------------

	#------------------------------FUN��ES------------------------------------

	#-------------------------------------------------------------------------
	# falar da fun��o aqui
	#
	#
	
	draw_point:

		####### coordenada #######
		
  		li a7, 4
  		la a0, str_coord_x
  		ecall
  	
    		li a7, 5
  		ecall
  		
  		mv t0, a0		# copiamos x pro t0
  		
  		li a7, 4
  		la a0, str_coord_y
  		ecall
  	
  		li a7, 5
  		ecall
  	
  		mv t1, a0		# copiamos y pro t1
  		
  		li t4, 4
  		li t3, 64
  		
  		addi t1, t1, -1		# config y 
  		mul t1, t1, t4
  		mul t1, t1, t3

  		addi t0, t0, -1		# config x
  		mul  t0, t0, t4		
  		
  		mv t5, a4		# passagem de paramentro (o come�o certo)
  		
  		sub t5, t5, t1
  		add t5, t5, t0
  		
  		####### cor #######
  		
  		li a7, 4
  		la a0, str_pega_R
  		ecall

		li a7, 5
  		ecall
		
		mv t0, a0
		slli t0, t0, 16		# rota��o do red pra esquerda

   		li a7, 4
  		la a0, str_pega_G
  		ecall
  		
  		li a7, 5
  		ecall
  		
  		mv t1, a0
  		slli t1, t1, 8		# rota��o do green pra esquerda
  		
   		li a7, 4
  		la a0, str_pega_B
  		ecall  		
  		
 		li a7, 5
  		ecall
		
  		mv t2, a0
  		
  		add t0, t0, t1		# acumula tudo no t0 e bota no ponto
  		add t0, t0, t2
  		
  		######load#########
  		
		mv t2, t5		# posi��o
		mv t3, t0 		# cor
		sw t3, 0(t2)		# printa na tela

		jr ra			# da return
		
	#-------------------------------------------------------------------------
	# Funcao load_image: carrega uma imagem em formato RAW RGB para memoria
	# Formato RAW: sequencia de pixels no formato RGB, 8 bits por componente
	# de cor, R o byte mais significativo
	#
	# Parametros:
	#  a0: endereco do string ".asciz" com o nome do arquivo com a imagem
	#  a1: endereco de memoria para onde a imagem sera carregada
	#  a2: endereco de uma palavra na memoria para utilizar como buffer
	#  a3: tamanho da imagem em pixels
	#
	# A fun��o foi implementada ... (explica��o da fun��o)
  
	load_image:
		# salva os par�metros da fun�ao nos tempor�rios
		mv t0, a0		# nome do arquivo
		mv t1, a1		# endereco de carga
		mv t2, a2		# buffer para leitura de um pixel do arquivo
	
		# chamada de sistema para abertura de arquivo
		#par�metros da chamada de sistema: a7=1024, a0=string com o diret�rio da imagem, a1 = defini��o de leitura/escrita
		li a7, 1024		# chamada de sistema para abertura de arquivo
		li a1, 0		# Abre arquivo para leitura (pode ser 0: leitura, 1: escrita)
		ecall			# Abre um arquivo (descritor do arquivo � retornado em a0)
		mv s6, a0		# salva o descritor do arquivo em s6
	
		mv a0, s6		# descritor do arquivo 
		mv a1, t2		# endere�o do buffer 
		li a2, 3		# largura do buffer
	
	#loop utilizado para ler pixel a pixel da imagem
	loop:  
		
		beq a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
		
		#chamada de sistema para leitura de arquivo
		#par�metros da chamada de sistema: a7=63, a0=descritor do arquivo, a1 = endere�o do buffer, a2 = m�ximo tamanho pra ler
		li a7, 63				# defini��o da chamada de sistema para leitura de arquivo 
		ecall            		# l� o arquivo
		lw   t4, 0(a1)   		# l� pixel do buffer	
		sw   t4, 0(t1)   		# escreve pixel no display
		addi t1, t1, 4  		# pr�ximo pixel
		addi a3, a3, -1  		# decrementa countador de pixels da imagem
		
		j loop
		
		# fecha o arquivo 
	close:
		# chamada de sistema para fechamento do arquivo
		#par�metros da chamada de sistema: a7=57, a0=descritor do arquivo
		li a7, 57		# chamada de sistema para fechamento do arquivo
		mv a0, s6		# descritor do arquivo a ser fechado
		ecall           # fecha arquivo
			
		jr ra
	
  
  
