class_name ESChase
extends EnemyState


@export var chase_speed : float = 100

# true while the enemy waits at a ledge or wall instead of running off it / into it
var blocked : bool = false

func enter() -> void:
	blocked = false
	enemy.play_animation( animation_name if animation_name else "walk" )
	pass

func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( _delta : float ) -> void:
	var dir : float = sign( blackboard.target.global_position.x - enemy.global_position.x )
	enemy.change_dir( dir )
	# EdgeSensor flags a drop ahead; test_move (not is_on_wall) so standing at a wall stays blocked
	var is_blocked : bool = blackboard.edge_detected or enemy.test_move( enemy.global_transform, Vector2( dir * 2.0, 0 ) )
	_set_blocked( is_blocked )
	enemy.velocity.x = 0.0 if is_blocked else dir * chase_speed
	pass


func _set_blocked( value : bool ) -> void:
	if value == blocked:
		return
	blocked = value
	if blocked and enemy.animation.has_animation( "idle" ):
		enemy.play_animation( "idle" )
	elif not blocked:
		enemy.play_animation( animation_name if animation_name else "walk" )
	pass
