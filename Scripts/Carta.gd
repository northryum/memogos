extends Area3D

# Referência ao nó Pivot, que contém a malha 3D
@onready var pivot = $"Pivot - Node3D"

var is_flipped = false
var is_animating = false # Trava de segurança para não bugar se o jogador clicar rápido demais

# Função chamada automaticamente quando o jogador clica na Area3D
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# Detecta o clique com o botão esquerdo do mouse (ou toque na tela no Android)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_animating:
			virar_carta()

func virar_carta():
	is_animating = true
	is_flipped = !is_flipped
	
	# Calcula a rotação alvo (180 graus no eixo Z para virar)
	var target_rotation = 180.0 if is_flipped else 0.0
	
	# Cria o Tween para a rotação (suave)
	var tween_rot = create_tween()
	tween_rot.tween_property(pivot, "rotation_degrees:z", target_rotation, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# Cria um Tween separado para o efeito de "pulo" (sobe e desce no eixo Y)
	var tween_pulo = create_tween()
	# Sobe a carta
	tween_pulo.tween_property(pivot, "position:y", 0.5, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	# Desce a carta de volta para a mesa
	tween_pulo.tween_property(pivot, "position:y", 0.0, 0.2)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		
	# Espera a animação de rotação terminar para liberar novos cliques
	await tween_rot.finished
	is_animating = false
