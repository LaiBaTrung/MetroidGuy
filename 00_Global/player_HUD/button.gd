extends Button

@export var particles_settings: HitParticleSettings

func _ready() -> void:
	pressed.connect(_on_pressed)
	pass
	
func _on_pressed() -> void:
	var pos : Vector2 = get_tree().get_first_node_in_group( "Player" ).global_position
	VisualEffects.hit_particales( pos, Vector2(0, -1 ), particles_settings )
	pass
