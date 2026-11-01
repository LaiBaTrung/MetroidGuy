class_name ESIdle
extends EnemyState

var duration : float = 0
var timer : float = 0
var done : bool = false

func enter() -> void:
	enemy.velocity.x = 0
	var anim : String = animation_name if animation_name else "idle"
	enemy.play_animation( anim )
	duration = enemy.animation.current_animation_length
	timer = 0
	done = false
	blackboard.can_decide = false
	pass
	
func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( delta : float ) -> void:
	enemy.velocity.x = 0
	# timer instead of awaiting animation_finished: a stun mid-idle no longer resumes this later
	timer += delta
	if timer >= duration and not done:
		done = true
		enemy.change_dir( -blackboard.dir )
		blackboard.hit_patrol_limit = false
		blackboard.can_decide = true
	pass
