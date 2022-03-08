extends KinematicBody #O tipo de node, interfere nas funções que estarão disponíveis

var Axys = Vector2(0, 0) #Variável que armazenará o vetor de movimentação
const MouseCenter = Vector2(683, 384) #Constante que armazenará a posição central
var NormalSpeed = 200 #Variável que armazena a velocidade do nosso jogador
var CurrentAnimation = "idle" #Variável que armazena a animação em execução
var NewAnimation = "idle" #Variável que armazenará uma nova animação para execução
var Shooting = false #Variável booleana que só aceita valor true ou falos (verdadeiro ou falso), armazena se o jogador esta atirando
onready var BulletHole = preload("res://bullethole.tscn") #Variável que carrega os buracos de tiro para podermos criar cópias em nosso jogo

func _ready(): #Função executada apenas uma vez quando o nosso jogador passa a existir
	get_viewport().warp_mouse(MouseCenter) #Posicionando o mouse no centro da tela
	pass

func _input(event): #Função executada toda vez que o jogador faz alguma interação seja no teclado, mouse, joystick ou qualquer outro controle
	var rot = - (get_viewport().get_mouse_position() - MouseCenter) / 150 #Variavel que calcula a diferença de posição do mouse desde o último frame
	get_viewport().warp_mouse(MouseCenter) #Reseta a posição do mouse para podermos realizar o calculo novamente da diferença de posição
	rotation += Vector3(0,rot.x,0) #Rotaciona o jogador no eixo horizontal
	$Camera.rotation += Vector3(rot.y,0,0) #E a câmera no eixo vertical
	$Camera.rotation.x = clamp($Camera.rotation.x, - deg2rad(90), deg2rad(90))
	
	if event.is_action_pressed("bshoot"): #Verificamos se o botão de tiro foi pressionado
		if $Camera/camray.get_collider() != null: #Verificamos se o raio colidiu com alguma coisa solida
			var o = BulletHole.instance() #Colocamos uma cópia do buraco de bala que criamos
			var offset = $Camera/camray.get_collision_point() - $Camera/camray.get_collider().translation #Calcula a posição relativa em que houve a colisão
			var vectorimpulse = - Vector3(sin(rotation.y),sin($Camera.rotation.x),cos(rotation.y)) #Monstamos um vetor para aplicarmos de impulso no objeto que houve a colisão
			$Camera/camray.get_collider().add_child(o) #Adicionamos o buraco de bala como filho do objeto que houve a colisão, assim ele herdara a posição e demais propriedades
			o.global_transform.origin = $Camera/camray.get_collision_point() #Posicionamos o buraco de bala onde houve a colisão 
			o.look_at($Camera/camray.get_collision_point() + $Camera/camray.get_collision_normal(), Vector3.UP) #Rotacionamos o buraco de bala
			if $Camera/camray.get_collider().is_in_group("softbody"): #Se o objeto não for estático podemos aplicar o impulso
				$Camera/camray.get_collider().apply_impulse(offset, vectorimpulse * 4.5) #Usamos como primeiro parâmetro o local relativo que houve a colisão e como segundo parâmetro o vetor de impulso que montamos multiplicado por uma força
				$Camera/camray.get_collider().Shooted(1)
			if $Camera/camray.get_collider().is_in_group("enemy"):
				$Camera/camray.get_collider().damage(1)
		NewAnimation = "shooting" #Solicitamos uma nova animação
		Shooting = true #E atribuimos a está variável o valor de verdadeira
	
	if event.is_action_pressed("bendgame"): #Se pressionarmos esse botão
		get_tree().quit() #Encerre o jogo
	elif event.is_action_pressed("bup"): #Ou se pressionamos esse botão
		Axys.y = - 1 #Então montamos o vetor de movimentação
	elif event.is_action_released("bup"): #Ou se a tecla for solta
		Axys.y = 0 #Zeramos
	elif event.is_action_pressed("bdown"):
		Axys.y = 1
	elif event.is_action_released("bdown"):
		Axys.y = 0
	elif event.is_action_pressed("bright"):
		Axys.x = 1
	elif event.is_action_released("bright"):
		Axys.x = 0
	elif event.is_action_pressed("bleft"):
		Axys.x = - 1
	elif event.is_action_released("bleft"):
		Axys.x = 0
	pass

func _process(delta):
	var SideVector = transform.basis.z #Vetor de movimentação para frente
	var HoriVector = transform.basis.x #Vetor de movimentação para os lados
	var MoveVector = (SideVector * Axys.y + HoriVector * Axys.x).normalized() * delta * NormalSpeed #Fazendo a multiplicação pelo vetor Axys temos a movimentaçao do jogador de acordo com a tecla pressionada
	#usamos a função normalized() para ajustar em um valor correto e multiplicamos pelo delta e pela velocidade.
	move_and_slide(MoveVector,Vector3.UP) #Aqui aplicamos a movimentação
	if !Shooting:#Se o jogador NÃO estiver atirando
		if abs(Axys.x) > 0 || abs(Axys.y) > 0: #E se algum eixo do teclado estiver sendo pressionado, lembrando que a função abs retira o sinal
			NewAnimation = "run" #Solicitamos a animação de correndo
		else: #Caso contrário
			NewAnimation = "idle" #A animação de parado
	if CurrentAnimation != NewAnimation: #Verificamos se as variáveis possuem valores diferentes
		CurrentAnimation = NewAnimation #Igualamos o valor delas
		$AnimationPlayer.play(CurrentAnimation) #E executamos a nova animação
	pass

func _on_AnimationPlayer_animation_finished(anim_name): #Quando a animação chega ao fim
	if anim_name == "shooting": #Se a animação for igual a "shooting" (atirando)
		Shooting = false #Mude o valor da váriavel atirando para falso
	pass
