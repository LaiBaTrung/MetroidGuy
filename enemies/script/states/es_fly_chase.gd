class_name ESFlyChase
extends EnemyState

@export var chase_speed : float = 100
## while it has seen the player it hovers this high above the player's feet...
@export var hover_height : float = 64
## ...and this far to the side it is already on, so it never lands next to the player
@export var hover_side : float = 40
## gentle bob while hovering: pixels up/down and full bobs per second
@export var bob_height : float = 4
@export var bob_rate : float = 1.5

# slows down this close to its hover spot, so it settles instead of jittering
const ARRIVE_DISTANCE : float = 24

var time : float = 0

func enter() -> void:
	enemy.play_animation( animation_name if animation_name else "chase" )
	time = 0
	pass

func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( delta : float ) -> void:
	if blackboard.target == null:
		return
	time += delta
	var target_pos : Vector2 = blackboard.target.global_position
	var side : float = signf( enemy.global_position.x - target_pos.x )
	if side == 0:
		side = -blackboard.dir
	var bob : float = sin( time * bob_rate * TAU ) * bob_height
	var hover_pos : Vector2 = target_pos + Vector2( side * hover_side, -hover_height + bob )
	assert( hover_pos.y < target_pos.y, "ESFlyChase: the hover spot must be above the player (hover_height > bob_height)" )
	var to_hover : Vector2 = hover_pos - enemy.global_position
	var speed : float = chase_speed * clampf( to_hover.length() / ARRIVE_DISTANCE, 0.0, 1.0 )
	enemy.velocity = to_hover.normalized() * speed
	# always face the player, even while drifting sideways to its hover spot
	var face : float = signf( target_pos.x - enemy.global_position.x )
	if face != 0:
		enemy.change_dir( face )
	pass
