#-------------------------------------------------------------------------------------------
#		Organização e Arquitetura de Computadores - Turma C 
#			Trabalho 1 - Assembly RISC-V
#				Unb -2/2019
#
# Nome: Gabriel Matheus			Matrícula: 17/0103498
# Nome: Guilherme Braga			Matrícula: 17/0162290
# Nome: Victor Eduardo			Matrícula: 17/0115127
#
# Link para o trabalho no Github --> https://github.com/therealguib545/OAC_Trabalho1
#
#-------------------------------------------------------------------------------------------

.data 

	# Strings de propriedades da imagem
	
	image_name:   	.asciz "lenaeye.raw"			# nome da imagem a ser carregada
	address: 	.word   0x10040000			# endereco do bitmap display na memoria	
	addr_coord:	.word   0x10043F00			# 0 cartesiano
	
	buffer:		.word   0			        # configuracao default do RARS
	size:		.word	4096				# numero de pixels da imagem

	# Strings de interação com o usuário

	str_menu:	.asciz "Defina o número da opção desejada:\n\n1- Obtém Ponto\n2- Desenha ponto\n3- Desenha retângulo com preenchimento\n4- Desenha retângulo sem preenchimento\n5- Converte para o negativo da imagem\n6- Converte imagem para tons de vermelho\n7- Carrega imagem\n8- Encerra\n\n"									 
	str_coord_x:	.asciz "Digite o valor da coordenada X: "	
	str_coord_y: 	.asciz "Digite o valor da coordenada Y: "
	str_coord_xf:	.asciz "Digite o valor da coordenada Xf: "	
	str_coord_yf: 	.asciz "Digite o valor da coordenada Yf: "
	str_pega_R:	.asciz "Digite o valor da componente R: "
	str_pega_G:	.asciz "Digite o valor da componente G: "
	str_pega_B:	.asciz "Digite o valor da componente B: "
	str_comp_R:	.asciz "\nComponente R: "
	str_comp_G:	.asciz "\nComponente G: "
	str_comp_B:	.asciz "\nComponente B: "
	str_coord1:	.asciz "\nDigite a sua primeira coordenada - \n"
	str_coord2:	.asciz "\nDigite a sua segunda coordenada - \n"
	str_cor:	.asciz "\nDigite os valores que descrevem a cor - \n"
	str_espaco:	.asciz "\n\n"
	str_erro:	.asciz "\nPor favor selecione uma opção válida!\n\n"
	

.text

#-------------------------------------------------------------------------------------------
### Criação de macros auxiliares para as funções ###

.macro printf($string)			# função que printa uma string na tela

	li a7, 4
  	la a0, $string
  	ecall
  	
.end_macro
  
.macro scanf($dest)			# função que lê input e salva no destino
		 	
  	li a7, 5
  	ecall	
  	mv $dest, a0	
  	
.end_macro 	 	
  
.macro push($pushAddr)			# função que armazena resgistro na pilha

	addi sp, sp, -4			# atualizamos o Stack Pointer
	sw   $pushAddr, 0(sp)		# e damos store word na pilha (para armazenar) no lugar correto

.end_macro  

.macro pop($popAddr)			# função que retira resgistro da pilha

	lw  $popAddr, 0(sp)		# e damos load word na pilha (para ler o que estava guardado) no lugar correspondente
  	addi sp, sp, 4			# atualizamos o Stack Pointer

.end_macro 
	 	 		 	 		 	 		 	 	 	 	 	 	
.macro to_coord($x, $y, $dest)		# função que transforma x e y no endereço de memória referente, devolvendo no destino o endereço formatado
 				
 	# para o funcionamento desta função, usamos a conta: 
 	
 	# numX = x
 	# numY = (64+y)
 	# resultado = (numX.numY.4) - 4
	# resultado = 0xresultado + end. base	
 					
        push(s0)			# guarda contexto
        push(s1)
        push($x)
        push($y)  
 
  	li s1, 4			# t3 e t4 como constantes
  	li s0, 64
  		
  	addi $y, $y, -1			# config y 
  	mul $y, $y, s1
  	mul $y, $y, s0

  	addi $x, $x, -1			# config x
  	mul  $x, $x, s1		
  		
  	mv $dest, a4			# parametro do começo da imagem
  		
  	sub $dest, $dest, $y		# acumulamos o valor no destino
  	add $dest, $dest, $x
  	
  	pop($y)				# restaura o contexto
        pop($x)
  	pop(s1)
  	pop(s0)
  	
.end_macro

.macro RGB_maker($R, $G, $B, $dest) 	# transforma R, G e B em um único hexa e devolve no destino
	
	push(s0)			# guarda contexto
	push(s1)
	push(s2)
	
	mv s0, $R
	mv s1, $G
	mv s2, $B
	
	slli s0, s0, 16			# rotaciona red pra esquerda
  	
  	slli s1, s1, 8			# rotaciona green pra esquerda
  		  		
  	add s0, s0, s1
  	add s0, s0, s2			# soma blue
  	
  	mv  $dest, s0			# move o resultado para o destino

	pop(s2)				# restaura o contexto
	pop(s1)
	pop(s0)
	
.end_macro

.macro draw_point_v2($x, $y, $cor)	# função que desenha o ponto na tela, dada as coordenadas x e y e a cor desejada

	push(t3)			# guarda contexto
	push(t2)


	to_coord($x, $y, t2)
	
	mv t3, $cor
	sw t3, 0(t2)			# printa na tela
	
	pop(t2)				# restaura o contexto
	pop(t3)
	
.end_macro  

.macro break_RGB($x, $y, $R, $G, $B)	

  	push(s0)
  	push(s1)			# guarda contexto
  	push(s2)
  	push(s6)
  	push(t6)
  		
  	to_coord($x, $y, s6)
  	
  	lw s1, 0(s6)			
  	
  	li s0, 0x10000			# pega R
  	div s2, s1, s0
  		
  	mv  $R, s2	
  		
  	li s0, 0x100			# pega G		
  	slli s2, s2, 16
  	sub s1, s1, s2 
  	div s2, s1, s0
  	
  	mv $G, s2
  	
  	slli s2, s2, 8			# pega G
  	sub $B, s1, s2			
	
	pop(t6)
	pop(s6)
	pop(s2)				# restaura o contexto
	pop(s1)
	pop(s0)
	
.end_macro  
#-------------------------------------------------------------------------------------------

	### Programa Efetivo ###

	menu:					# loop base do programa

		li a6, 0			# inicializa a variavel de comparação

		printf(str_menu)				
     		scanf(a6)			# le do usuario o input da escolha
     
     		# switch case 
     		
		li a2, 1			# comparamos sempre o input do usuario em a6 com a variavel a2			
		beq a6, a2, pega_ponto		# a2 é atualizada sempre antes de uma comparação
						# se a comparação é satisfeita, pulamos para a parte de chamada de função
		li a2, 2
		beq a6, a2, desenha_ponto
	
		li a2, 3
		beq a6, a2, desenha_ret_p 
	
		li a2, 4
		beq a6, a2, desenha_ret_vazio
	
		li a2, 5
		beq a6, a2, inverte_imagem
	
		li a2, 6
		beq a6, a2, converte_vermelho
	
		li a2, 7
		beq a6, a2, carrega_imagem
	
		li a2, 8
		beq a6, a2, fim
		
		printf(str_erro)		# Mostramos uma mensagem de erro caso o input do usuário não seja uma opção real
	
		b menu				# jump default, onde esperamos o input correto
		
	#-------------------------------------------------------------------------
	# Área para a chamada de funções 
	# Primeiro, define-se os parâmetros corretos para cada chamada de função.
	# Após a defição, chamamos a função desejada e damos retorno para o começo do Menu
	#
	
	carrega_imagem: 
		
 		la a0, image_name		# define parâmetros e chama a função para carregar a imagem
		lw a1, address
		la a2, buffer
		lw a3, size
		jal load_image			# chama a função
	
		b menu				# retorna pro menu
	
	desenha_ponto:
	
		lw a4, addr_coord		# configura parâmentro do 0 cartesiano
		jal draw_point			# chama a função
	
		b menu				# retorna pro menu
  	
	pega_ponto:
	
		lw a4, addr_coord		# configura parâmentro do 0 cartesiano
		jal get_point			# chama a função
	
		b menu 				# retorna pro menu
	
	desenha_ret_p:

		lw a4, addr_coord		# configura parâmentro do 0 cartesiano
		jal draw_full_rectangle		# chama a função
 
 		b menu 				# retorna pro menu
 	
	desenha_ret_vazio:

		lw a4, addr_coord		# configura parâmentro do 0 cartesiano
		jal draw_empty_rectangle	# chama a função
	
		b menu 				# retorna pro menu
	
	inverte_imagem:

		lw a4, addr_coord		# configura parâmentro do 0 cartesiano
		jal convert_negative		# chama a função	
	
		b menu 				# retorna pro menu
 
 	converte_vermelho:

		lw a4, addr_coord		# configura parâmentro do 0 cartesiano
		jal convert_red			# chama a função
	
		b menu 				# retorna pro menu
 
	fim:
	
		li a7, 10			# FIM	
		ecall				# definição da chamada de sistema para encerrar programa
	
	#---------------------------FINAL DA MAIN---------------------------------

	#------------------------------FUNÇÕES------------------------------------
	
	#-------------------------------------------------------------------------
	# Função draw_point: Responsável por desenhar um único ponto na tela, dada 
	# as coordenadas e a cor
	#
	# Parametros:
	# - Coordenada de início da imagem (passada pelo programa)
	# - Input do usuário para X e Y (coordenadas)
	# - Input do usuário para R, G e B (descrição da cor do ponto a ser desenhado)
	#
	# Como funciona: Com o input do usuário, a função calcula o endereço correspondente 
	# no bitmap, acessa esse endereço e escreve o valor de cor formatado neste local da
	# memória. 
	#
		
	draw_point:
		
  		printf(str_coord_x)		# leitura das coordenadas
  	  	scanf(t0)
  		
  		printf(str_coord_y)
  		scanf(t1)
  		
 	 	printf(str_pega_R)		# leitura da cor
		scanf(t2)
	
   		printf(str_pega_G)	
  		scanf(t3)
  		
   		printf(str_pega_B)			
 		scanf(t4)
  		
		RGB_maker(t2, t3, t4, t6)	# formatamos o input para o formato correto de desenho
	
		draw_point_v2(t0, t1, t6)	# desenha no bitmap

		jr ra				# retorna da função 

	#-------------------------------------------------------------------------
	# Função get_point: Responsável por ler a cor de um ponto dada as coordenadas
	#
	# Parametros:
	# - Coordenada de início da imagem (passada pelo programa)
	# - Input do usuário para X e Y (coordenadas)
	#
	# Como funciona: Acessamos o endereço dado pelo usuário (após formatado com a
	# respectiva macro), e então acessamos os valoresem RGB. Os valores são dados como:
	# xxRRGGBB (em bits). Usando divisões para "isolar" os bits menos significativos
	# e rotações para fazer com que os valores que se deseja ler sejam os que estão mais 
	# à direita, podemos isolar os valores respectivos e fornece-los ao usuário.  
	#
		
	get_point:
	
		printf(str_coord_x)		# leitura das coordenadas
    		scanf(t0)
  		
  		printf(str_coord_y)
  		scanf(t1)
  		
  		break_RGB(t0, t1, t2, t3, t4) 
  	
  		printf(str_comp_R)
  	
  		li a7, 1			# printa número
  		mv a0, t2
  		ecall
  		
  		printf(str_comp_G)
  	
  		li a7, 1			# printa número
  		mv a0, t3
  		ecall 
  		
  		printf(str_comp_B)
  	
  		li a7, 1
  		mv a0, t4
  		ecall
  	
  		printf(str_espaco)
  	  	  	
  		jr ra				# retorna	
	
	#-------------------------------------------------------------------------
	# Função draw_full_rectangle: Responsável por desenhar um retângulo cheio dado a 
	# cor e 2 pontos de diagonais opostas (cartesiano)
	#
	# Parametros:
	# - Coordenada de início da imagem (passada pelo programa)
	# - Input do usuário para X e Y (coordenadas iniciais)
	# - Input do usuário para X e Y (coordenadas finais)
	# - Input do usuário para R, G e B (descrição da cor do retângulo a ser desenhado)
	#
	# Como funciona: Com os pontos dados pelo usuário (e após a definição de qual é o ponto mais
	# perto da origem e qual é o ponto mais longe da origem), e o valor RGB, definimos as variáveis "delta X" e
	# "delta Y", sendo estas as variações de X e Y entre as coordenadas. Com o auxílio de um contador, 
	# printamos os pontos com um dado valor RGB ao longo do eixo X (soma-se 0x4 ao endereço para deslocarmos para o ponto ao lado em X),
	# "delta X" vezes. Após essa operação, vamos para a linha de cima à linha (soma-se 0x100) de inicio e printamos a linha em X. 
	# Subtraimos o que foi somado para deslocarmos no eixo X. Repetimos o processo "delta Y" vezes. 
	#
										
	draw_full_rectangle:

		printf(str_coord1)

		printf(str_coord_x)
    		scanf(t0)            		# X inicial
  		
  		printf(str_coord_y)
  		scanf(t1)            		# Y inicial
  		
  		printf(str_coord2)
  		
  		printf(str_coord_x)
    		scanf(t2)             		# X final
  		
  		printf(str_coord_y)
  		scanf(t3)            		# Y final
 	
 		bge t2, t0, rect_f_continue
 		push t2		    		# troca os 2 caso a afirmativa Xfinal > Xinicial é falsa
 		push t0
 		pop t2
 		pop t0

	rect_f_continue:
 		bge t3, t1, rect_f_continue2
 		push t3		     		# troca os 2 caso a afirmativa Yfinal > Yinicial é falsa
 		push t1
 		pop t3
 		pop t1

	rect_f_continue2:
	
		printf(str_cor)
		
  		printf(str_pega_R)		# leitura das cores
		scanf(t4)
	
   		printf(str_pega_G)
  		scanf(t5)
  			
   		printf(str_pega_B)			
 		scanf(t6)
  		
 		RGB_maker(t4, t5, t6, t6)   	# os valores RGB vão para t6 no formato correto de print

		addi t2, t2, 1
		mv t4, t0			# contador do x
		mv t5, t1			# contador do y
		
	loop_ret:				# desenha horizontal x
		beq t4, t2, zera_x_incrementa_y		# checamos condição de update em Y 
		
		draw_point_v2(t4, t5, t6)		# desenhamos ponto a ponto em X
	
		addi t4, t4, 1				# atualizamos o contador
	
		j loop_ret 		# efetuamos o loop
	
	zera_x_incrementa_y:			# desenha vertical y

		beq t5, t3, fim_rect_f		# checamos se estamos no último Y possivel
	
		mv t4, t0			# reseta x
		addi t5, t5, 1			# contamos quantas linhas em Y fizemos

		j loop_ret			# voltamos para o loop
	
	fim_rect_f:

		jr ra			# retornamos da função 
	
	#-------------------------------------------------------------------------
	# Função draw_rect_full: Responsável por desenhar a borda de um retângulo, 
	# dado a cor e 2 pontos de diagonais opostas (cartesiano)
	#
	# Parametros:
	# - Coordenada de início da imagem (passada pelo programa)
	# - Input do usuário para X e Y (coordenadas iniciais)
	# - Input do usuário para X e Y (coordenadas finais)
	# - Input do usuário para R, G e B (descrição da cor do retângulo a ser desenhado)
	#
	# Como funciona: Com os pontos dados pelo usuário (e após a definição de qual é o ponto mais
	# perto da origem e qual é o ponto mais longe da origem) e o valor RGB, definimos as variáveis "delta X" e
	# "delta Y", sendo estas as variações de X e Y entre as coordenadas. Primeiramente fazemos
	# as linhas na direção X, uma partindo da origem da coordenada mais perto da origem e outra deslocada
	# exatamante "delta Y" para cima. Fazemos pontos e os incrementamos (0x4) à esquerda "delta X" vezes.
	# Após fazer estas linhas, fazemos linhas na direção de Y, uma começando no ponto mais perto à
	# origem e outra linha deslocada "delta X" à direita. Fazemos os pontos e os incrementamos (0x100)
	# "delta Y" vezes
	#
	
	draw_empty_rectangle:

		printf(str_coord1)

		printf(str_coord_x)
   	 	scanf(t0)             		# X 1
  		
  		printf(str_coord_y)
  		scanf(t1)            		# Y 1
  		
  		printf(str_coord2)
  		
  		printf(str_coord_x)
    		scanf(t2)             		# X 2
  		
  		printf(str_coord_y)
  		scanf(t3)            		# Y 2
 		
 		bge t2, t0, rect_vazio_continue
 		push t2		     		# troca os 2 caso a afirmativa Xfinal > Xinicial é falsa
 		push t0
 		pop t2
 		pop t0

	rect_vazio_continue:
 		bge t3, t1, rect_vazio_continue2
 		push t3		    		# troca os 2 caso a afirmativa Yfinal > Yinicial é falsa
 		push t1
 		pop t3
 		pop t1

	rect_vazio_continue2:
	
		printf(str_cor)
  		
  		printf(str_pega_R)		# leitura das cores
		scanf(t4)
	
   		printf(str_pega_G)
  		scanf(t5)
  			
   		printf(str_pega_B)		
 		scanf(t6)
  		
 		RGB_maker(t4, t5, t6, t6)    	# RGB vai no formato correto para t6

		mv t4, t0			# contador do x
		mv t5, t1			# contador do y
	
	XfYf_XYf_loop:				# desenha horizontal (esquerda -> direita)
	
		beq t4, t2, XYf_XY_loop		# checa condição de parada
	
		draw_point_v2(t4, t5, t6)	# desenha o ponto
	
		addi t4, t4, 1			# incrementa contador
	
		j XfYf_XYf_loop 		# loop incondicional

	XYf_XY_loop:				# desenha vertical (baixo -> cima)

		beq t5, t3, XY_XfY_loop		# checa condição de parada
	
		draw_point_v2(t4, t5, t6)	# desenha o ponto
	
		addi t5, t5, 1			# incrementa contador
	
		j XYf_XY_loop			# loop incondicional

	XY_XfY_loop:				# desenha horizontal (direita -> esquerda)

		beq t4, t0, XfY_XfYf_loop	# checa condição de parada

		draw_point_v2(t4, t5, t6)	# desenha o ponto
		
		addi t4, t4, -1			# incrementa contador
	
		j XY_XfY_loop			# loop incondicional

	XfY_XfYf_loop:				# desenha vertical (cima -> baixo)

		beq t5, t1, fim_ret_vazio	# checa condição de parada

		draw_point_v2(t4, t5, t6)	# desenha o ponto
	
		addi t5, t5, -1			# incrementa contador
	
		j XfY_XfYf_loop			# loop incondicional

	fim_ret_vazio:
	
		jr ra				# fim

	#-------------------------------------------------------------------------
	# Função convert_negative: Responsável por passar uma imagem com valores em
	# RGB para o sua forma negativa
	#
	# Parametros:
	

	convert_negative:

		li t0, 1 			# x
		li t1, 1			# y
		li s0, 255
		li s1, 65

	loop_convert_negative:
			
		break_RGB(t0, t1, t2, t3, t4)
	
		sub t2, s0, t2
		sub t3, s0, t3
		sub t4, s0, t4
		
		RGB_maker(t2, t3, t4, t5)

		draw_point_v2(t0, t1, t5)
	
		addi t0, t0, 1
	
		beq  t0, s1, anda_y
	
		b loop_convert_negative
	
	anda_y:
		beq  t1, s1, fim_convert_negative
		addi t1, t1, 1
		li t0, 1
	
		b loop_convert_negative
	
	
	fim_convert_negative:
		jr ra

	#-------------------------------------------------------------------------
	# Função convert_red: Responsável por passar uma imagem com valores em
	# RGB para o sua forma avermelhada, apenas com seus valores da componente
	# R (red) sendo levados em consideração
	#
	# Parametros:
	#
	

	convert_red:

		li t0, 1 			# x
		li t1, 1			# y
		li s1, 65

	loop_convert_red:
			
		break_RGB(t0, t1, t2, t3, t4)
	
		li t3, 0
		li t4, 0 
	
		RGB_maker(t2, t3, t4, t5)

		draw_point_v2(t0, t1, t5)
	
		addi t0, t0, 1
	
		beq  t0, s1, anda_y_r
	
		b loop_convert_red
	
	anda_y_r:
		beq  t1, s1, fim_convert_red
		addi t1, t1, 1
		li t0, 1
		
		b loop_convert_red
		
	
	fim_convert_red:
		jr ra							
																					
	#-------------------------------------------------------------------------
	# Funcao load_image: carrega uma imagem em formato RAW RGB para memoria
	# Formato RAW: sequencia de pixels no formato RGB, 8 bits por componente
	# de cor, R o byte mais significativo 
	#
	# (Essa função nos foi disponibilizada pelo professor da matéria!)
	#
	# Parametros:
	#  a0: endereco do string ".asciz" com o nome do arquivo com a imagem
	#  a1: endereco de memoria para onde a imagem sera carregada
	#  a2: endereco de uma palavra na memoria para utilizar como buffer
	#  a3: tamanho da imagem em pixels
	#
	# A função foi implementada chamando o arquivo especificado, lendo 
	# pixel a pixel da imagem, lançando-o num buffer e printando cada um
	# no bitmap
  
	load_image:
		# salva os parãmetros da função nos temporários
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
		ecall            		# le o arquivo
		lw   t4, 0(a1)   		# le pixel do buffer	
		sw   t4, 0(t1)   		# escreve pixel no display
		addi t1, t1, 4  		# próximo pixel
		addi a3, a3, -1  		# decrementa countador de pixels da imagem
		
		j loop
		
		# fecha o arquivo 
	close:
		# chamada de sistema para fechamento do arquivo
		#parãmetros da chamada de sistema: a7=57, a0=descritor do arquivo
		li a7, 57		# chamada de sistema para fechamento do arquivo
		mv a0, s6		# descritor do arquivo a ser fechado
		ecall           	# fecha arquivo
			
		jr ra

