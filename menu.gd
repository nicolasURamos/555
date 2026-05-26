extends Control

@onready var btn_acordar = $VBoxContainer/acordar
@onready var btn_dormir =$VBoxContainer/dormir

func _ready():
	# Libera o mouse para o jogador poder clicar nos botões
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Conecta os botões
	btn_acordar.pressed.connect(_on_acordar_pressed)
	btn_dormir.pressed.connect(_on_dormir_pressed)

func _on_acordar_pressed():
	# Carrega a fase principal do jogo. 
	# ATENÇÃO: Verifique se o nome do seu mapa é esse mesmo!
	get_tree().change_scene_to_file("res://nivel_teste.tscn")

func _on_dormir_pressed():
	# Fecha o jogo e volta para o Windows/Desktop
	get_tree().quit()
