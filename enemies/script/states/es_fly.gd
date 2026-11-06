class_name ESFly
extends EnemyState

@export var speed : float = 50
## patrol bob: how far it drifts up and down (pixels) and how many full bobs per second
@export var bob_height : float = 6
@export var bob_rate : float = 0.8

var left_limit : float
var right_limit : float
var time : float = 0

func _ready() -> void:
	_set_limit()
	pass

func enter() -> void:
	var anim : String = animation_name if animation_name else "fly"
	enemy.play_animation( anim )
	time = 0
	pass

func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( delta : float ) -> void:
	if enemy.is_on_wall():
		enemy.change_dir( -blackboard.dir )
	elif enemy.global_position.x <= left_limit and blackboard.dir < 0:
		enemy.change_dir( 1.0 )
	elif enemy.global_position.x >= right_limit and blackboard.dir > 0:
		enemy.change_dir( -1.0 )
	# vertical speed of a sine bob: it drifts bob_height up and down and never wanders off
	time += delta
	var w : float = bob_rate * TAU
	enemy.velocity = Vector2( speed * blackboard.dir, bob_height * w * cos( time * w ) )
	pass


func _set_limit() -> void:
	left_limit = owner.global_position.x - 5000
	right_limit = owner.global_position.x + 5000

	for c in owner.get_children():
		if c is PatrolLimit:
			if c.side == Side.SIDE_LEFT:
				left_limit = c.global_position.x
			else:
				right_limit = c.global_position.x
	pass
