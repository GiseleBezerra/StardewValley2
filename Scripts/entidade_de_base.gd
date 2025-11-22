extends CharacterBody2D

var direcao: Vector2
var esta_correndo: bool = false
var personagem: CharacterBody2D
var _esta_atacando:bool = false

@export var _tempo_de_caminhada: Timer 
@export var _tempo_de_corrida: Timer
@export var _tempo_de_ataque: Timer 
@export var _animador: AnimationPlayer
@onready var _textura: Sprite2D = $Texture
@export var _velocidade_de_movimento_normal: float = 32.0
@export var _velocidade_de_movimento_correndo: float = 64.0
@export var _vida: int = 10
@export var _entidade_agressiva: bool = false

func _ready() -> void:
	direcao = retornar_derecao_aleatoria()
	_tempo_de_caminhada.start(5.0)
	
func _physics_process(_delta: float) -> void:
	velocity = _velocidade_de_movimento_normal * direcao
	if esta_correndo:
		velocity = _velocidade_de_movimento_correndo * direcao
		
	if is_instance_valid(personagem) and personagem.esta_vivo == true:
		var distancia: float = global_position.distance_to(personagem.global_position)
		if distancia < 16:
			if _esta_atacando == false:
				personagem.sofrendo_dano(randi_range(1,3))
				_tempo_de_ataque.start()
				_esta_atacando = true
			print("pode atacar")
			
			return
			
		direcao = global_position.direction_to(personagem.position)
		# essa lnha faz um calculo de onde a direção do personagem esta
		velocity = _velocidade_de_movimento_normal * direcao
	move_and_slide()
	_bounce()
	_animar()
	
	
func _bounce() -> void:
	if get_slide_collision_count() > 0:
		direcao = velocity.bounce(get_slide_collision(0).get_normal()).normalized()
		pass
	
	
func _animar() -> void:
	if velocity.x > 0:
		_textura.flip_h = false
	if velocity.x < 0:
		_textura.flip_h = true
	if velocity != Vector2(0,0):
		_animador.play("andando")
		return
	_animador.play("parado")


func retornar_derecao_aleatoria() -> Vector2:
	return Vector2(
		[-1,0,+1].pick_random(), # metodo de lista
		[-1,0,+1].pick_random()
	).normalized() #aqui normalizamos o vetor
	

func _on_tempo_de_caminhada_timeout() -> void:
	_tempo_de_caminhada.start(5.0)
	
	if direcao != Vector2(0,0):
		direcao = Vector2(0,0)
		return
	if direcao == Vector2(0,0):
		direcao = retornar_derecao_aleatoria()


func perdendo_vida(_dano_recebido: int) -> void:
	_vida -= _dano_recebido
	if _vida > 0:
		$AnimadorVida.play("perdendo_vida")
		if _entidade_agressiva:
			return
			
		direcao = retornar_derecao_aleatoria()
		_tempo_de_corrida.start(5.0)
		_tempo_de_caminhada.stop()
		esta_correndo = true
		return
	_kill()
	

func _kill() -> void:
	if _entidade_agressiva:
		set_physics_process(false)
		_animador.play("morrendo")
		return
	queue_free()

func _on_tempo_de_corrida_timeout() -> void:
	_tempo_de_caminhada.start(5.0)
	esta_correndo = false


func _on_area_de_deteccao_body_entered(_body: Node2D) -> void:
	if _entidade_agressiva == false:
		return
		
	if _body.is_in_group("personagem"):
		_tempo_de_caminhada.start(5.0)
		personagem = _body
		
		print("Entrou")


func _on_area_de_deteccao_body_exited(_body: Node2D) -> void:
	if _entidade_agressiva == false:
		return
	
	if _body.is_in_group("personagem"):
		_tempo_de_caminhada.start(5.0)
		personagem = null
		print("Saiu")


func _on_tempo_de_ataque_timeout() -> void:
	_esta_atacando = false


func _on_animador_animation_finished(anim_name: StringName) -> void:
	if anim_name == "morrendo":
		queue_free()
		
