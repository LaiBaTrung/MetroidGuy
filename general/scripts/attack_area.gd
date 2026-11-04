@icon("res://general/icons/attack_area.svg")
extends Area2D
class_name AttackArea

@export var damage : float = 1

# hit feel, only when the player is involved (seconds of freeze, camera shake strength)
const HIT_STOP_DEALT : float = 0.08
const HIT_STOP_TAKEN : float = 0.12
const HIT_SHAKE_DEALT : float = 1.5


func _ready() -> void:
	body_entered.connect( _on_body_entered )
	area_entered.connect( _on_body_entered )
	visible = false
	monitorable = false
	monitoring = false
	pass
	
func _on_body_entered(body : Node2D) -> void:
	if body is DamageArea:
		body.take_damage( self )
		var pos : Vector2 = global_position
		pos.x = body.global_position.x
		VisualEffects.hit_dust( pos )
		# hitstop only when the player is involved: its own hits, or the player getting hit
		if owner is Player:
			VisualEffects.hit_stop( HIT_STOP_DEALT )
			VisualEffects.camera_shake( HIT_SHAKE_DEALT )
		elif body.owner is Player:
			VisualEffects.hit_stop( HIT_STOP_TAKEN )
		pass
	pass
	
	
func activate( duration : float = 0.1 ) -> void:
	set_active()
	await  get_tree().create_timer( duration  ).timeout
	set_active( false )
	pass
	
	
func set_active( value : bool = true ) -> void:
	monitoring = value
	visible = value
	pass
	
	
func flip( direction_x : float  ) -> void:
	if direction_x > 0:
		scale.x = 1
	elif direction_x < 0:
		scale.x = -1
	pass
