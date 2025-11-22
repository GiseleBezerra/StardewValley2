extends CanvasLayer

func atualizar_arma_atual(_nova_arma: String) -> void:
	$VContainer/ArmaAtual.text = "Arma Atual: " + _nova_arma
	pass
	
func _atualizar_vida_do_personagem(_vida_atual: int, _vida_maxima: int) -> void:
	if _vida_atual < 0:
		_vida_atual = 0
	$VContainer/Vida.text = "Vida: " + str(_vida_atual) + "/" + str(_vida_maxima)
