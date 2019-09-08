.data

	image_name:   	.asciz "lenaeye.raw"	# nome da imagem a ser carregada
	address: 	.word   0x10040000			# endereco do bitmap display na memoria	
	addr_coord:	.word   0x10043F00			#1 pra baixo = +100, 1 pra direita, é +4
	#0x10043F00 = canto inferior esquerdo
	#0x10043FFC = canto inferior direito
	#0x10040000 = canto superior esquerdo
	#0x100400FC = canto superior direito
	buffer:		.word   0			        # configuracao default do RARS
	size:		.word	4096				# numero de pixels da imagem

	str_menu:	.asciz "Defina o número da opção desejada:\n\n1- Obtém Ponto\n2- Desenha ponto\n3- Desenha retângulo com preenchimento\n4- Desenha retângulo sem preenchimento\n5- Converte para o negativo da imagem\n6- Converte imagem para tons de vermelho\n7- Carrega imagem\n8- Encerra\n\n"									 

	str_coord_x:	.asciz "Digite o valor da coordenada X: "	
	str_coord_y: 	.asciz "Digite o valor da coordenada Y: "
	str_pega_R:	.asciz "Digite o valor da componente R: "
	str_pega_G:	.asciz "Digite o valor da componente G: "
	str_pega_B:	.asciz "Digite o valor da componente B: "
	str_comp_R:	.asciz "\nComponente R: "
	str_comp_G:	.asciz "\nComponente G: "
	str_comp_B:	.asciz "\nComponente B: "
	str_espaco:	.asciz "\n\n"
	

.text

.macro to_coord($x, $y)
 
  	li t4, 4		#t3 e t4 como constantes
  	li t3, 64
  		
  	addi $y, $y, -1		# config y 
  	mul $y, $y, t4
  	mul $y, $y, t3

  	addi $x, $x, -1		# config x
  	mul  $x, $x, t4		
  		
  	mv t5, a4		# passagem de paramentro (o começo certo)
  		
  	sub t5, t5, $y
  	add t5, t5, $x
.end_macro

menu:

	li a6, 0		# reseta a6, onde fica a opção do usuário

	li a7, 4
  	la a0, str_menu		# printa o menu
  	ecall
  	
     	li a7, 5		# da scanf
  	ecall
  		
  	mv a6, a0		# botamos a6
	li a2, 1		# comparação para branch de função 
	
	beq a6, a2, pega_ponto

	li a2, 2
	beq a6, a2, desenha_ponto
	
	#sucessivamente se incrementa a2, compara com a sua função respectiva
	
	li a2, 7
	beq a6, a2, carrega_imagem
	
	li a2, 8
	beq a6, a2, fim
	

carrega_imagem: 
		
 	# define parâmetros e chama a função para carregar a imagem
	la a0, image_name
	lw a1, address
	la a2, buffer
	lw a3, size
	jal load_image
	
	b menu
	
desenha_ponto:
	
	# parametro usado para fazer o ponto
	lw a4, addr_coord
	jal draw_point		#ta fazendo o ponto versão 1.0 é nois
	
	b menu
  	
pega_ponto:
	
	#parametro usado para fazer o ponto
	lw a4, addr_coord
	jal get_point		#ta fazendo o ponto versão 1.0 é nois
	
	b menu 	
 
fim:

	# FIM
	# definição da chamada de sistema para encerrar programa	
	# parâmetros da chamada de sistema: a7=10
	li a7, 10		
	ecall
	
	#---------------------------FINAL DA MAIN---------------------------------

	#------------------------------FUNÇÕES------------------------------------

	#-------------------------------------------------------------------------
	# falar da função aqui
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
  		
  	to_coord(t0, t1)
  	####### cor #######
  		
  	li a7, 4
  	la a0, str_pega_R
  	ecall

	li a7, 5
  	ecall
		
	mv t0, a0
	slli t0, t0, 16		# rotação do red pra esquerda

   	li a7, 4
  	la a0, str_pega_G
 	ecall
  		
  	li a7, 5
  	ecall
  		
  	mv t1, a0
  	slli t1, t1, 8		# rotação do green pra esquerda
  		
   	li a7, 4
  	la a0, str_pega_B
  	ecall  		
  		
 	li a7, 5
  	ecall
		
  	mv t2, a0
  		
  	add t0, t0, t1		# acumula tudo no t0 e bota no ponto
  	add t0, t0, t2
  		
  	###### load #########
  		
	mv t2, t5		# posição
	mv t3, t0 		# cor
	sw t3, 0(t2)		# printa na tela

	jr ra			# da return

get_point:
	
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
  		
  	to_coord(t0, t1)
  	
  	li t0, 0x10000
  	lw t1, 0(t5)
  	
  	#t5 está com a coordenada
  	#pega R
  	
  	li t0, 0x10000
  	lw t1, 0(t5)
  	
  	div t2, t1, t0
  	
  	#printar t2 (R)
  	
  	li a7, 4
  	la a0, str_comp_R
  	ecall
  	
  	li a7, 1
  	mv a0, t2
  	ecall
  	
  	li t0, 0x100
  	
  	slli t2, t2, 16

  	#pega G
  	
  	sub t1, t1, t2 
  	div t2, t1, t0
  	
  	#printar t2 (G)
  	
  	li a7, 4
  	la a0, str_comp_G
  	ecall
  	
  	li a7, 1
  	mv a0, t2
  	ecall 
  	
  	slli t2, t2, 8
  	
  	#pega B
  	
  	sub t1, t1, t2
  	
  	#printar t1 (B)
  	
  	li a7, 4
  	la a0, str_comp_B
  	ecall
  	
  	li a7, 1
  	mv a0, t1
  	ecall
  	
  	li a7, 4
  	la a0, str_espaco
  	ecall
  	  	  	
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
	# A função foi implementada ... (explicação da função)
  
load_image:
	# salva os parâmetros da funçao nos temporários
	mv t0, a0		# nome do arquivo
	mv t1, a1		# endereco de carga
	mv t2, a2		# buffer para leitura de um pixel do arquivo
	
	# chamada de sistema para abertura de arquivo
	#parâmetros da chamada de sistema: a7=1024, a0=string com o diretório da imagem, a1 = definição de leitura/escrita
	li a7, 1024		# chamada de sistema para abertura de arquivo
	li a1, 0		# Abre arquivo para leitura (pode ser 0: leitura, 1: escrita)
	ecall			# Abre um arquivo (descritor do arquivo é retornado em a0)
	mv s6, a0		# salva o descritor do arquivo em s6
	
	mv a0, s6		# descritor do arquivo 
	mv a1, t2		# endereço do buffer 
	li a2, 3		# largura do buffer
	
	#loop utilizado para ler pixel a pixel da imagem
loop:  
		
	beq a3, zero, close		#verifica se o contador de pixels da imagem chegou a 0
		
	#chamada de sistema para leitura de arquivo
	#parâmetros da chamada de sistema: a7=63, a0=descritor do arquivo, a1 = endereço do buffer, a2 = máximo tamanho pra ler
	li a7, 63			# definição da chamada de sistema para leitura de arquivo 
	ecall            		# lê o arquivo
	lw   t4, 0(a1)   		# lê pixel do buffer	
	sw   t4, 0(t1)   		# escreve pixel no display
	addi t1, t1, 4  		# próximo pixel
	addi a3, a3, -1  		# decrementa countador de pixels da imagem
		
	j loop
		
	# fecha o arquivo 
close:
	# chamada de sistema para fechamento do arquivo
	#parâmetros da chamada de sistema: a7=57, a0=descritor do arquivo
	li a7, 57		# chamada de sistema para fechamento do arquivo
	mv a0, s6		# descritor do arquivo a ser fechado
	ecall           	# fecha arquivo
			
	jr ra


