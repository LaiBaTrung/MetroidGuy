class_name ESStun
extends EnemyState


@export var knockback_strength : float = 100
## after a stun ends, hits still hurt but do not stun again for this long (no stun-lock)
@export var stun_immunity : float = 0.6

var vel_x : float = 0
var duration : float = 0
var timer : float = 0
var _immune_until : int = 0

func start() -> void:
	var anim : String = animation_name if animation_name else "stun"
	if enemy.animation.current_animation == anim:
		enemy.animation.seek( 0 )
	else:
		enemy.play_animation( anim )
	duration = enemy.animation.current_animation_length
	timer = 0
	_calc_velocity( blackboard.damage_source )
	blackboard.damage_source = null
	blackboard.can_decide = false
	pass

func enter() -> void:
	start()
	
	pass
	
# a hit while already stunned still hurts and pushes, but no longer restarts the stun:
# restarting it on every combo hit kept the enemy stunned for as long as the player kept swinging
func re_enter() -> void:
	_calc_velocity( blackboard.damage_source )
	blackboard.damage_source = null
	pass

func exit() -> void:
	blackboard.can_decide = true
	_immune_until = Time.get_ticks_msec() + int( stun_immunity * 1000.0 )
	pass


func can_stun() -> bool:
	return Time.get_ticks_msec() >= _immune_until

func physics_update( delta : float ) -> void:
	timer += delta
	enemy.velocity.x = vel_x * ( 1 - timer / duration )
	if timer >= duration:
		blackboard.can_decide = true
	pass
	  
func	_calc_velocity( a : AttackArea ) -> void:
	vel_x = 1
	if a.global_position.x > enemy.global_position.x:
		vel_x = -1
	vel_x *= knockback_strength
	pass
