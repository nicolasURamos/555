extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("verificar_vitoria"):
			body.verificar_vitoria()
