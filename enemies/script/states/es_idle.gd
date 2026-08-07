class_name ESIdle
extends EnemyState

func enter() -> void:
	enemy.velocity.x = 0
	var anim : String = animation_name if animation_name else "idle"
	enemy.play_animation( anim )
	blackboard.can_decide = false
	await enemy.animation.animation_finished
	enemy.change_dir( -blackboard.dir )
	blackboard.hit_patrol_limit = false
	blackboard.can_decide = true
	pass
	
func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( _delta : float ) -> void:
	enemy.velocity.x = 0
	pass
