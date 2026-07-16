extends Node2D
class_name Trap

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hazard_area: HazardArea = $HazardArea


@export var start_delay: float = 0.0
@export var damage : float = 1.0

func _ready() -> void:
	hazard_area.damage = damage
	await get_tree().create_timer(start_delay).timeout
	animation_player.play("cycle")
	
	
