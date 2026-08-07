class_name ESFlyChase
extends EnemyState

@export var chase_speed : float = 100

func enter() -> void:
	enemy.play_animation( animation_name if animation_name else "chase" )
	pass
	
func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( _delta : float ) -> void:
	if blackboard.target != null:
		var dir : Vector2 = enemy.global_position.direction_to( blackboard.target.global_position )
		enemy.change_dir( sign( dir.x ) )
		enemy.velocity = dir * chase_speed
	pass
