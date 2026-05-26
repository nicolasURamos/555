extends Area3D

# --- Referências dos Nós ---
@onready var som_coleta = $SomColeta
@onready var collision_shape = $CollisionShape3D
@onready var case_low2 = $case_low2
@onready var efeito_brilho = $EfeitoBrilho

func _ready():
	# Conecta o sinal de entrada de corpos automaticamente
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Se quem encostar tiver a função coletar_epi (nosso Player)
	if body.has_method("coletar_epi"):
		body.coletar_epi() # Avisa o jogador para subir o número na tela
		
		# 1. Desliga a colisão para não coletar duas vezes
		collision_shape.set_deferred("disabled", true)
		
		# 2. Faz a maleta e o brilho sumirem da tela na hora
		case_low2.visible = false
		efeito_brilho.visible = false
		
		# 3. Toca o som de pegar o item
		som_coleta.play()
		
		# 4. Espera o som acabar
		await som_coleta.finished
		
		# 5. Destrói o item definitivamente
		queue_free()
