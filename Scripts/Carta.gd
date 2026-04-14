extends Area2D
class_name CARTA

signal carta_clicada(carta)

# Pegamos referências aos novos nós
@onready var pivot = $Pivot
@onready var costa = $Pivot/Costa
@onready var face = $Pivot/Face

var is_flipped = false
var is_animating = false

var nipe_atual: String
var valor_atual: String

# Parâmetro de tamanho_slot adicionado
func configurar_carta(n: String, v: String, tamanho_slot: Vector2):
	nipe_atual = n
	valor_atual = v
	
	# Carrega as texturas
	var textura_costa = GameControl.cardback
	costa.texture = textura_costa
	
	var caminho_face = "res://Assets/temas/Spade_Cards/card-" + nipe_atual + "-" + valor_atual + ".png"
	var textura_face = load(caminho_face)
	face.texture = textura_face
	
	# --- Lógica de Auto-Escala ---
	# Pegamos o tamanho da textura original (supomos que costa e face tenham o mesmo tamanho)
	var tamanho_textura = textura_costa.get_size()
	
	# Calculamos a escala necessária para a textura caber no slot
	# A proporção da textura deve ser mantida.
	var proporcao_textura = tamanho_textura.x / tamanho_textura.y
	var proporcao_slot = tamanho_slot.x / tamanho_slot.y
	
	var escala_final = 1.0
	
	# Se a proporção do slot for mais "larga" que a textura, a altura do slot limita.
	if proporcao_slot > proporcao_textura:
		escala_final = tamanho_slot.y / tamanho_textura.y
	# Caso contrário, a largura do slot limita.
	else:
		escala_final = tamanho_slot.x / tamanho_textura.x
		
	# Aplicamos a escala ao nó Pivot
	pivot.scale = Vector2(escala_final, escala_final)
	# -----------------------------
	
	# Estado inicial: Mostra só as costas
	face.visible = false
	costa.visible = true
	is_flipped = false

func _ready():
	# Conectamos o sinal input_event da própria raiz à função local.
	# Isso garante que a função _on_input_event seja chamada ao clicar.
	self.connect("input_event", _on_input_event)

# A função _on_input_event agora funciona corretamente
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_animating and not is_flipped:
			emit_signal("carta_clicada", self)

# A animação de virar também é aplicada ao Pivot
func _virar_carta():
	is_animating = true
	
	# Animação 1: Encolhe o Pivot no eixo X
	var tween_fechar = create_tween()
	# Mantemos o scale:y intacto
	tween_fechar.tween_property(pivot, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	await tween_fechar.finished
	
	# Troca a imagem
	is_flipped = !is_flipped
	face.visible = is_flipped
	costa.visible = !is_flipped
	
	# Animação 2: Abre o Pivot de volta para o scale original (calculado na configuração)
	# Pegamos a escala final calculada na configuração.
	var escala_final = pivot.scale.y
	
	var tween_abrir = create_tween()
	# Mantemos o scale:y intacto
	tween_abrir.tween_property(pivot, "scale:x", escala_final, 0.15).set_trans(Tween.TRANS_SINE)
	await tween_abrir.finished
	
	is_animating = false

func desvirar():
	if is_flipped and not is_animating:
		_virar_carta()
