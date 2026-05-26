extends Area3D

# Quantidade de cargas que este item específico vai dar ao jogador
@export var cargas_para_adicionar : int = 2

func _ready():
	# Conecta o sinal de colisão automaticamente por código
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verifica se o corpo que encostou na pilha tem a função de receber cargas
	if body.has_method("adicionar_cargas"):
		body.adicionar_cargas(cargas_para_adicionar)
		queue_free() # Remove a pilha do mapa (destrói o item coletado)
