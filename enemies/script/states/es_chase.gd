class_name ESChase
extends EnemyState


@export var chase_speed : float = 100
## seconds the enemy waits at a wall or ledge it cannot pass before it gives up the chase
@export var give_up_time : float = 1.5
## seconds it then walks away (or waits, if that way is blocked too) before chasing again
@export var give_up_duration : float = 2.0
@export var give_up_speed : float = 50

# a collision normal at least this horizontal is a wall; flatter ones are floor corners
const WALL_NORMAL_MIN_X : float = 0.7

# true while the enemy waits at a ledge or wall instead of running off it / into it
var blocked : bool = false
var blocked_time : float = 0
var give_up_timer : float = 0


func _ready() -> void:
	assert( give_up_time > 0 and give_up_duration >= 0, "ESChase: give_up_time must be > 0" )
	pass

func enter() -> void:
	blocked = false
	blocked_time = 0
	give_up_timer = 0
	enemy.play_animation( animation_name if animation_name else "walk" )
	pass

func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( delta : float ) -> void:
	var speed : float = chase_speed
	if give_up_timer > 0:
		# gave up: keep walking the way it turned
		give_up_timer -= delta
		speed = give_up_speed
	else:
		var dir_to_target : float = sign( blackboard.target.global_position.x - enemy.global_position.x )
		if dir_to_target != 0:
			enemy.change_dir( dir_to_target )
	var dir : float = blackboard.dir
	# a wall check rather than is_on_wall, so an enemy standing at a wall stays blocked
	var is_blocked : bool = blackboard.edge_detected or _wall_ahead( dir )
	_set_blocked( is_blocked )
	enemy.velocity.x = 0.0 if is_blocked else dir * speed

	# turn away after a while instead of staring at a wall or ledge forever
	if is_blocked and give_up_timer <= 0:
		blocked_time += delta
		if blocked_time >= give_up_time:
			blocked_time = 0
			give_up_timer = give_up_duration
			enemy.change_dir( -dir )
	elif not is_blocked:
		blocked_time = 0

	# idle does not loop: restart it so a waiting enemy never freezes on its last frame
	if blocked and not enemy.animation.is_playing() and enemy.animation.has_animation( "idle" ):
		enemy.animation.stop()
		enemy.play_animation( "idle" )
	pass


# test_move alone also hits floor-tile corners (normal mostly up), so only a facing wall counts
func _wall_ahead( dir : float ) -> bool:
	var col : KinematicCollision2D = KinematicCollision2D.new()
	if not enemy.test_move( enemy.global_transform, Vector2( dir * 2.0, 0 ), col ):
		return false
	var n : Vector2 = col.get_normal()
	return absf( n.x ) > WALL_NORMAL_MIN_X and signf( n.x ) == -signf( dir )


func _set_blocked( value : bool ) -> void:
	if value == blocked:
		return
	blocked = value
	if blocked and enemy.animation.has_animation( "idle" ):
		enemy.play_animation( "idle" )
	elif not blocked:
		enemy.play_animation( animation_name if animation_name else "walk" )
	pass
