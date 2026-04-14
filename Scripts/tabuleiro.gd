extends Node3D

# @export permite que você altere esses valores direto no Inspector (tela da direita)
@export var carta_cena: PackedScene # Aqui vamos colocar a nossa cena da carta
@export var linhas: int = 4
@export var colunas: int = 4
@export var espacamento: float = 2.2 # Distância entre uma carta e outra

func _ready():
	gerar_tabuleiro()

func gerar_tabuleiro():
	# Calculamos um offset (deslocamento) para que o grid fique centralizado no meio da tela
	var offset_x = (colunas - 1) * espacamento / 2.0
	var offset_z = (linhas - 1) * espacamento / 2.0
	
	for x in range(colunas):
		for z in range(linhas):
			# Instancia uma cópia da cena da carta
			var nova_carta = carta_cena.instantiate()
			
			# Adiciona a carta como "filha" do Tabuleiro
			add_child(nova_carta)
			
			# Calcula a posição 3D exata no grid
			var pos_x = (x * espacamento) - offset_x
			var pos_z = (z * espacamento) - offset_z
			
			# Move a carta para a posição calculada
			nova_carta.position = Vector3(pos_x, 0, pos_z)
			
			# Opcional: dá um nome organizado para cada carta na árvore de nós
			nova_carta.name = "Carta_%d_%d" % [x, z]
