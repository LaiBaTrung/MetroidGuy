extends Button

@export var particles_settings: HitParticleSettings

func _ready() -> void:
	pressed.connect(_on_pressed)
	pass
	
func _on_pressed() -> void:
	var player : Player = get_tree().get_first_node_in_group("Player")
	player.dash = !player.dash
	pass
