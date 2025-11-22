extends Area2D
@export var arma_que_destroi: String
@export var _vida: int = 10

func perda_de_vida(_dano: int) -> void:
	_vida -= _dano
	if _vida > 0:
		$AnimationPlayer.play("perdendo_vida")
		return
	queue_free()
	
