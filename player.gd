extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# --- Movimentação e Pulo ---
const WALK_SPEED = 3.5
const SPRINT_SPEED = 6.5
const JUMP_VELOCITY = 4.5 
var current_speed = WALK_SPEED

# --- Sistema de Stamina ---
var max_stamina = 10.0
var current_stamina = 10.0
var is_exhausted = false

# --- Variáveis de Câmera, Olho (Luz) e UI ---
@onready var camera = $Camera3D
@onready var flashlight = $Camera3D/SpotLight3D
@onready var label_cargas = $CanvasLayer/Label
@onready var barra_stamina = $CanvasLayer/BarraStamina

# --- Variáveis do Cronômetro e Game Over ---
@onready var label_timer = $CanvasLayer/Label_Timer
@onready var tela_game_over = $CanvasLayer/TelaGameOver
@onready var btn_restart = $CanvasLayer/TelaGameOver/Btn_Restart
@onready var btn_menu = $CanvasLayer/TelaGameOver/Btn_Menu

# --- Variáveis do Som ---
@onready var som_passos = $SomPassos
var tempo_entre_passos = 0.5 # Aumente para passos mais lentos, diminua para mais rápidos
var timer_passos = 0.0

# --- Inventário de EPIs ---
var epis_coletados = 0
var TOTAL_EPIS = 3 # Ajuste este número para o total exato de maletas no mapa

var tempo_restante: float = 300.0 
var jogo_acabou: bool = false

# --- Sistema de Sono (Substitui a Bateria) ---
var max_battery = 100.0 
var current_battery = 100.0
var drain_rate = 8.0 # <--- Aumentado: Agora o sono vem muito mais rápido!
var max_light_energy = 6.0

# --- Sistema de Missão (EPIs e Vitória) ---
@onready var label_epis = $CanvasLayer/Label_EPIs
@onready var tela_vitoria = $CanvasLayer/TelaVitoria
@onready var btn_reiniciar_vitoria = $CanvasLayer/TelaVitoria/Btn_ReiniciarVitoria


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	tela_game_over.hide()
	tela_vitoria.hide()
	atualizar_hud()
	
	# Conectando os botões
	btn_restart.pressed.connect(_on_restart_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)
	btn_reiniciar_vitoria.pressed.connect(_on_restart_pressed)

func _input(event):
	if jogo_acabou: return 
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * 0.2))
		camera.rotate_x(deg_to_rad(-event.relative.y * 0.2))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _process(delta):
	if not jogo_acabou:
		tempo_restante -= delta
		if tempo_restante <= 0:
			tempo_restante = 0
			acionar_game_over()
		
		var minutos = int(tempo_restante) / 60
		var segundos = int(tempo_restante) % 60
		label_timer.text = "%02d:%02d" % [minutos, segundos]

	# --- Sistema do Olho / Sono ---
	if current_battery > 0:
		current_battery -= drain_rate * delta
	else:
		current_battery = 0
		
	# Efeito de "Pálpebra Pesada" (Começa a piscar quando o sono abaixa de 30)
	if current_battery < 30.0:
		# Usa o tempo do motor para criar um piscar caótico
		var piscar = abs(sin(Time.get_ticks_msec() * 0.005))
		flashlight.light_energy = (current_battery / max_battery) * max_light_energy * piscar
	else:
		# Visão normal diminuindo aos poucos
		flashlight.light_energy = (current_battery / max_battery) * max_light_energy
	
	# Botão de "Acordar / Arregalar os olhos"
	if Input.is_action_just_pressed("recharge"):
		current_battery = max_battery 

func _physics_process(delta):
	if jogo_acabou: return 
	
	# --- Pulo ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("ui_accept"): 
		velocity.y = JUMP_VELOCITY

	# --- Direção ---
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_moving = direction.length() > 0

	# --- Sistema de Stamina ---
	if Input.is_action_pressed("sprint") and is_moving and not is_exhausted:
		current_speed = SPRINT_SPEED
		current_stamina -= delta
		if current_stamina <= 0:
			current_stamina = 0
			is_exhausted = true
	else:
		current_speed = WALK_SPEED
		if current_stamina < max_stamina:
			current_stamina += delta
			if current_stamina >= max_stamina:
				current_stamina = max_stamina
				is_exhausted = false

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	
	# --- Controle de Som dos Passos ---
	var velocidade_horizontal = Vector2(velocity.x, velocity.z).length()
	
	if is_on_floor() and velocidade_horizontal > 0.5:
		# O timer vai diminuindo de acordo com o relógio do jogo (delta)
		timer_passos -= delta
		
		# Quando o timer zera, ele toca o som UM passo e reseta o relógio
		if timer_passos <= 0.0:
			# Varia levemente o tom (pitch) para não parecer um robô andando
			som_passos.pitch_scale = randf_range(0.9, 1.1) 
			som_passos.play()
			timer_passos = tempo_entre_passos
	else:
		# Se ele parar de andar, reseta o timer para o próximo passo sair na hora certa
		timer_passos = 0.0
	
	if barra_stamina:
		barra_stamina.value = current_stamina

# --- Funções Extras ---
func coletar_epi():
	if epis_coletados < TOTAL_EPIS:
		epis_coletados += 1
		atualizar_hud()

func atualizar_hud():
	if label_epis:
		label_epis.text = "EPIs: " + str(epis_coletados) + "/" + str(TOTAL_EPIS)

# --- Funções de Fim de Jogo ---
func acionar_game_over():
	jogo_acabou = true
	tela_game_over.show() 
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	get_tree().paused = true 

func verificar_vitoria():
	if epis_coletados >= TOTAL_EPIS:
		jogo_acabou = true
		tela_vitoria.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		print("Você não possui todos os EPIs necessários para encerrar o expediente!")

func _on_restart_pressed():
	get_tree().paused = false 
	get_tree().reload_current_scene() 

func _on_menu_pressed():


	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
