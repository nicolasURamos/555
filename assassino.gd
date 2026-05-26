extends CharacterBody3D

var speed = 4.0 
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Distância aumentada para ignorar a colisão gordinha das cápsulas
var attack_distance = 2.2 
var atacando = false 

@onready var nav_agent = $NavigationAgent3D
@onready var anim = $PSX_BagMan/AnimationPlayer
@onready var som_passos = $SomPassos3D
var tempo_passos = 0.6 # Ajuste para sincronizar com a animação de caminhada dele
var timer_passos = 0.0
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# 1. Aplicar gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. Lógica Principal
	if player and not atacando:
		var distancia = global_position.distance_to(player.global_position)
		
		if distancia <= attack_distance:
			# --- MODO ATAQUE ---
			atacando = true 
			velocity = Vector3.ZERO 
			
			# Vira para o jogador usando a mesma regra da caminhada
			var direcao_ataque = global_position.direction_to(player.global_position)
			rotation.y = atan2(direcao_ataque.x, direcao_ataque.z)
			
			anim.play("Attack")
			
			await get_tree().create_timer(0.5).timeout
			if player.has_method("acionar_game_over"):
				player.acionar_game_over()
				
		else:
			# --- MODO PERSEGUIÇÃO ---
			nav_agent.target_position = player.global_position
			var next_pos = nav_agent.get_next_path_position()
			
			var direction = global_position.direction_to(next_pos)
			direction.y = 0 
			direction = direction.normalized()
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			# 3. Rotação Matemática e Som
			if Vector2(velocity.x, velocity.z).length() > 0.1:
				anim.play("Walk")
				
				# --- SOM DOS PASSOS DO MONSTRO ---
				timer_passos -= delta
				if timer_passos <= 0.0:
					som_passos.pitch_scale = randf_range(0.85, 1.05) # Som mais grave que o do jogador
					som_passos.play()
					timer_passos = tempo_passos
				# ---------------------------------
				
				var target_angle = atan2(velocity.x, velocity.z)
				rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
			else:
				anim.play("Idle")
				timer_passos = 0.0 # Reseta se ele parar

	# 4. Movimento Físico
	move_and_slide()
