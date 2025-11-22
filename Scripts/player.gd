extends CharacterBody2D
class_name player
var _vida_maxima: int
var _arma_atual: String = "_machado"
@export var _speed_pixel: float = 120
@export var _temporizador_de_acoes: Timer
@export var _area_de_ataque:Area2D 
@onready var _animador_do_personagem: AnimationPlayer = $Animation
@export var _texto_armar_atual: Label
@export var _interface: CanvasLayer
var direcao: Vector2 = Vector2.ZERO
var _sufixo_da_animacao: String = "_baixo" # sufixo da animacao
var _pode_atacar: bool = true
@export var _vida: int = 10
var esta_vivo: bool = true

func _ready() -> void:
	_vida_maxima = _vida
	pass


func _process(_delta: float) -> void:
	_animar()
	_atacar()
	_sufixo_da_animacao = _sufixo_do_personagem()
	_definir_arma_atual()
	
	_movimento_personagem()
	


func _movimento_personagem() -> void:  # responasavel pelo movimento do player
	direcao = Input.get_vector(
		"move_esquerda","move_direita","move_cima","move_baixo"
		)
		
	velocity = direcao  * _speed_pixel
	move_and_slide()


func _sufixo_do_personagem() -> String: 
	# responsavel pela 
	#animação do player em quanto ele se move
	#acao horizontal
	var acao_horizontal =  Input.get_axis("move_esquerda","move_direita")
	if acao_horizontal == -1:
		_area_de_ataque.position = Vector2(-17,0)
		return "_esquerda"
	if acao_horizontal == 1:
		_area_de_ataque.position = Vector2(16,0)
		return "_direita"
	#acao vertical
	var acao_vertical = Input.get_axis("move_cima", "move_baixo")
	if  acao_vertical == -1:
		_area_de_ataque.position = Vector2(0,-12)
		return "_cima"
	if acao_vertical == 1:
		_area_de_ataque.position = Vector2(0,17)
		return "_baixo"
		
	return _sufixo_da_animacao
	

func _definir_arma_atual() -> String: 
	var tipo_acao: String
	tipo_acao = "ataque_normal"
	if Input.is_action_pressed("machado_ataque"):
		_arma_atual = "_machado"
		tipo_acao = "machado_ataque"
	if Input.is_action_pressed("ataque_normal"):
		_arma_atual = "_espada"
		tipo_acao = "ataque_normal"
	if Input.is_action_pressed("picareta_ataque"):
		_arma_atual = "_picareta"
		tipo_acao = "picareta_ataque"
	if Input.is_action_pressed("enxada_ataque"):
		_arma_atual = "_enxada"
		tipo_acao = "enxada_ataque"
	if Input.is_action_pressed("regador_ataque"):
		_arma_atual = "_regador"
		tipo_acao = "regador_ataque"
	_interface.atualizar_arma_atual(_arma_atual)
	_texto_armar_atual.text = _arma_atual
	return tipo_acao


func _atacar() -> void:
	var acao: String = _definir_arma_atual()
	if Input.is_action_pressed(acao) and _pode_atacar: 
		_animador_do_personagem.play("atacar" + _arma_atual + _sufixo_da_animacao)
		_temporizador_de_acoes.start(0.4)
		set_process(false)
		_pode_atacar = false


func _animar() -> void: 
	if _pode_atacar == false: 
		return
	if velocity: 
		_animador_do_personagem.play("move" + _sufixo_da_animacao)
		return
	_animador_do_personagem.play("parado" + _sufixo_da_animacao)


func _on_temporizador_de_acoes_timeout() -> void:
	set_process(true)
	_pode_atacar = true

func _on_area_de_ataque_area_entered(_area: Area2D) -> void:
	if _area.is_in_group("area_de_dano"):
		_area.get_parent().perdendo_vida(randi_range(1,6))
		#print(_area.get_parent().name)
		return
	if _area.is_in_group("objetos"):
		if _arma_atual == _area.arma_que_destroi:
			_area.perda_de_vida(randi_range(1,5))

func sofrendo_dano(_dano_recebido: int) -> void:
	if esta_vivo == false: 
		return
	_vida -= _dano_recebido
	_interface._atualizar_vida_do_personagem(_vida, _vida_maxima)
	if _vida > 0:
		$AnimadorVida.play("perdendo_vida")
		return
	_kill()
	

func _kill() -> void:
	esta_vivo = false
	set_process(false)
	_animador_do_personagem.play("morte")
	


func _on_animation_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "morte":
		get_tree().change_scene_to_file("res://Cenas/interface/tela_de_game_over.tscn")
		print("chama tela de game over renicia o nivel")
		$Label.hide()
		$Collision.set_deferred("disabled",true)
		
