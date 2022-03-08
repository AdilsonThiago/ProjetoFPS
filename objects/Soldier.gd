extends KinematicBody

var Axys = Vector2(0, 0) #Variável que armazenará o vetor de movimentação
var ShootDelay = 0.0 #Intervalo para atirar
var Life = 5 #Quantidade de vida
var AllowMove = true #Controla se é permitido movimentação
var NormalSpeed = 160 #Variável que armazena a velocidade do nosso jogador
var Shooting = false #Variável booleana que só aceita valor true ou falos (verdadeiro ou falso), armazena se o jogador esta atirando
onready var BulletHole = preload("res://bullethole.tscn") #Variável que carrega os buracos de tiro para podermos criar cópias em nosso jogo
var AnimationMode = null #Recurso para fazer transições de animações

var objPlayer = null #Objeto alvo

func _ready():
	AnimationMode = $AnimationTree["parameters/StateMachine/playback"]
	$AnimationTree["parameters/StateMachine/normal/blend_position"].x = 0.0
	$AnimationTree["parameters/StateMachine/normal/blend_position"].y = 0.0
	pass

func _process(delta):
	if ShootDelay > 0:
		ShootDelay -= delta
	if objPlayer != null && AllowMove:
		var Distance = translation.distance_to(objPlayer.translation)
		rotation.y = Vector2(objPlayer.translation.z, objPlayer.translation.x).angle_to_point(Vector2(translation.z, translation.x))
		if Distance > 7.0 && ShootDelay <= 0:
			var SideVector = transform.basis.z
			var HoriVector = Vector3(0, 0, 0)
			var MoveVector = (SideVector + HoriVector).normalized() * NormalSpeed * delta
			move_and_slide(MoveVector,Vector3.UP)
			$AnimationTree["parameters/StateMachine/normal/blend_position"].x = 1.0
			$AnimationTree["parameters/StateMachine/normal/blend_position"].y = 0.0
		else:
			$AnimationTree["parameters/StateMachine/normal/blend_position"].x = 0.0
			$AnimationTree["parameters/StateMachine/normal/blend_position"].y = 0.0
			if ShootDelay <= 0:
				ShootDelay = 1.2
				AnimationMode.travel("Firing")
	pass

func damage(dmg):
	Life -= dmg
	if Life <= 0:
		AllowMove = false
		AnimationMode.travel("Death")
	pass

func _on_detectionarea_body_entered(body):
	if body.is_in_group("player"):
		objPlayer = body
	pass
