extends GridContainer

@export var carta_cena: PackedScene
@export var linhas: int = 4
@export var colunas: int = 4

var primeira_carta = null
var segunda_carta = null
var pode_clicar = true

func _ready():
	# Configuramos o número de colunas do GridContainer
	self.columns = colunas
	
	# O GridContainer gerencia o posicionamento, mas precisamos calcular o tamanho do slot
	# para passar para cada carta.
	_gerar_tabuleiro()

func _gerar_tabuleiro():
	# 1. Preparar a lista de pares
	var lista_cartas = []
	var total_pares = (linhas * colunas) / 2
	
	for i in range(total_pares):
		# Naipe fixo para o exemplo, valor dinâmico de i+1
		# Isso cria pares com valores de 1 a total_pares (ex: card-1-1.png)
		var config = {"nipe": "1", "valor": str(i + 1)}
		lista_cartas.append(config)
		lista_cartas.append(config) # Adiciona o par
	
	# Embaralha a lista
	lista_cartas.shuffle()
	
	# 2. Calcular o tamanho do slot da carta
	# Pegamos o tamanho total disponível do container. Como ele está como Full Rect,
	# é o tamanho da tela do jogo.
	var tamanho_tela = get_viewport_rect().size
	
	# Calculamos o slot para que o grid completo caiba na tela
	# O menor valor das dimensões calculadas será o tamanho do slot, para manter as proporções.
	var slot_width = tamanho_tela.x / colunas
	var slot_height = tamanho_tela.y / linhas
	
	# Usamos o menor valor para o tamanho do slot.
	# Isso garante que as cartas caibam e mantenham a proporção das texturas.
	var tamanho_slot_final = min(slot_width, slot_height)
	var tamanho_slot_vector = Vector2(tamanho_slot_final, tamanho_slot_final)
	# ---------------------------------------------
	
	# 3. Gerar as cartas
	var contador = 0
	# Não precisamos mais de loops de X e Y para posição.
	# Basta um loop para o total de cartas e add_child().
	# O GridContainer cuidará do posicionamento automático com base nas colunas.
	for i in range(linhas * colunas):
		# Instancia a carta
		var nova_carta = carta_cena.instantiate()
		
		# Adiciona como filha do GridContainer
		add_child(nova_carta)
		
		# Pega a informação da lista embaralhada
		var info = lista_cartas[contador]
		
		# Passa a info e o tamanho_slot calculado para a carta.
		nova_carta.configurar_carta(info.nipe, info.valor, tamanho_slot_vector)
		
		# Conecta o sinal do clique
		nova_carta.connect("carta_clicada", _ao_clicar_na_carta)
		
		# Dá um nome organizado (opcional, para depuração)
		nova_carta.name = "Carta_" + str(i + 1)
		
		contador += 1

# --- LÓGICA DO JOGO DE MEMÓRIA ---
# Esta parte permanece igual, pois é a lógica do jogo puro.

func _ao_clicar_na_carta(carta):
	# Se o tabuleiro estiver travado (esperando desvirar), ignora o clique
	if not pode_clicar: return
	
	# O tabuleiro autoriza a carta a virar e mostrar a face
	carta._virar_carta()
	
	# Lógica de seleção
	if primeira_carta == null:
		# É a primeira carta do par sendo virada
		primeira_carta = carta
	else:
		# É a segunda carta sendo virada! Vamos verificar se formou par.
		segunda_carta = carta
		_verificar_par()

func _verificar_par():
	# Trava o tabuleiro para o jogador não clicar em mais nada enquanto verifica
	pode_clicar = false
	
	# Verifica se acertou
	if primeira_carta.valor_atual == segunda_carta.valor_atual and primeira_carta.nipe_atual == segunda_carta.nipe_atual:
		# ACERTOU!
		print("Par encontrado!")
		
		# Limpa as variáveis para a próxima rodada
		primeira_carta = null
		segunda_carta = null
		
		# Destrava o tabuleiro
		pode_clicar = true
	else:
		# ERROU!
		print("Errou o par. Desvirando...")
		
		# Espera 1 segundo de forma "suave" para o jogador conseguir ver as cartas que errou
		await get_tree().create_timer(1.0).timeout
		
		# Manda as cartas tocarem a animação de desvirar
		primeira_carta.desvirar()
		segunda_carta.desvirar()
		
		# Limpa as variáveis para a próxima rodada
		primeira_carta = null
		segunda_carta = null
		
		# Destrava o tabuleiro
		pode_clicar = true
