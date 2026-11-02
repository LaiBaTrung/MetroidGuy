@icon("res://general/icons/damage_area.svg")
extends Area2D
class_name DamageArea

signal damage_taken( attack_area )

@export var audio : AudioStream 


func take_damage( attack_area : AttackArea ) -> void:
	damage_taken.emit( attack_area )
	if audio:
		Audio.play_spatial_sound( audio, global_position )
	pass
	

# invulnerable while any timed window runs or a start/end hold is on,
# so one source ending (e.g. a hit timer mid ground slam) never cuts another short
var _timed_windows : int = 0
var _held : bool = false


func make_invulnerable( duration : float = 1.0 ) -> void:
	_timed_windows += 1
	_update_invulnerable()
	await get_tree().create_timer( duration ).timeout
	_timed_windows -= 1
	assert( _timed_windows >= 0, "DamageArea: more invulnerable windows ended than started" )
	_update_invulnerable()
	pass

func start_invulnerable() -> void:
	_held = true
	_update_invulnerable()
	pass

func end_invulnerable() -> void:
	_held = false
	_update_invulnerable()
	pass


func _update_invulnerable() -> void:
	if _held or _timed_windows > 0:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
	pass
