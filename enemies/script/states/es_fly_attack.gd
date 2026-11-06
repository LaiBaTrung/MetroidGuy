class_name ESFlyAttack
extends EnemyState

# Dash: warns (rear back, shake, flash), then aims at the player and dashes in a straight line through that mark.

@export var attack_range : float = 100
## speed of the dash (pixels per second)
@export var move_speed : float = 200
@export var cooldown : float = 3
@export var attack_area : AttackArea
## how long it rears back, shakes and flashes before dashing (GDD melee minimum: 0.35 s)
@export var wind_up_time : float = 0.5
## how far the dash keeps going past the marked spot
@export var overshoot : float = 40
## marks this far above the player's feet (their middle), so on flat ground it skims past instead of hitting the floor at the mark
@export var aim_height : float = 23
## farthest sideways the player may be for it to attack
@export var max_reach : float = 80
## the player must be at least this far below to be attacked
@export var min_depth : float = 32
## deepest mark the dash may aim at
@export var max_depth : float = 100
## upward speed while winding up
@export var wind_up_rise : float = 25
## speed it backs away from the player while winding up
@export var wind_up_pull_back : float = 30
## flash colour while winding up (above 1.0 glows, the project uses HDR 2D)
@export var warning_color : Color = Color( 2.2, 1.3, 1.1, 1.0 )

const GLIDE_STOP : float = 2500           # px/s² it slows down after the dash: a short skid on the floor, a short drift in the air
const WARNING_FLASH_RATE : float = 8.0    # flashes per second
const SHAKE_RATE : float = 30.0           # shake steps per second
const SHAKE_PIXELS : float = 1.0

var timer : float = 0
var duration : float = 0
var on_cooldown : bool = false
var target_pos : Vector2
var dashing : bool = false
var dash_done : bool = false
var dash_dir : Vector2
var dash_time : float = 0

func enter() -> void:
	enemy.play_animation( animation_name if animation_name else "attack" )
	duration = enemy.animation.current_animation_length
	timer = 0
	blackboard.can_decide = false
	on_cooldown = true
	dashing = false
	dash_done = false
	target_pos = blackboard.target.global_position
	enemy.change_dir( signf( target_pos.x - enemy.global_position.x ) )
	if attack_area:
		attack_area.flip( blackboard.dir )
	pass

func re_enter() -> void:
	pass

func exit() -> void:
	blackboard.can_decide = true
	if attack_area:
		attack_area.set_active( false )
	_end_warning()
	run_cooldown()
	pass

func physics_update( delta : float ) -> void:
	timer += delta
	if timer >= duration:
		blackboard.can_decide = true

	if timer < wind_up_time:
		enemy.velocity = Vector2( -signf( target_pos.x - enemy.global_position.x ) * wind_up_pull_back, -wind_up_rise )
		_show_warning()
	elif not dash_done and ( not dashing or ( timer < wind_up_time + dash_time and enemy.get_slide_collision_count() == 0 ) ):
		if not dashing:
			_start_dash()
		enemy.velocity = dash_dir * move_speed
		# the animation's own activate() switches the area off after 0.2 s; keep it live for the dash
		if attack_area and not attack_area.monitoring:
			attack_area.set_active( true )
	else:
		if dashing:
			dashing = false
			dash_done = true
			if attack_area:
				attack_area.set_active( false )
		enemy.velocity = enemy.velocity.move_toward( Vector2.ZERO, GLIDE_STOP * delta )
	pass


func _show_warning() -> void:
	if not enemy.sprite:
		return
	var flash_on : bool = int( timer * WARNING_FLASH_RATE * 2.0 ) % 2 == 0
	enemy.sprite.self_modulate = warning_color if flash_on else Color.WHITE
	var shake_left : bool = int( timer * SHAKE_RATE ) % 2 == 0
	enemy.sprite.offset.x = -SHAKE_PIXELS if shake_left else SHAKE_PIXELS
	pass


func _end_warning() -> void:
	if not enemy.sprite:
		return
	enemy.sprite.self_modulate = Color.WHITE
	enemy.sprite.offset.x = 0.0
	pass


func _start_dash() -> void:
	_end_warning()
	dashing = true
	if blackboard.target:
		target_pos = blackboard.target.global_position + Vector2( 0, -aim_height )
	# clamped so a jump or a far player during the warning can't stretch the dash into a long charge
	var to_mark : Vector2 = target_pos - enemy.global_position
	to_mark.x = clampf( to_mark.x, -max_reach, max_reach )
	to_mark.y = clampf( to_mark.y, min_depth, max_depth )
	target_pos = enemy.global_position + to_mark
	dash_dir = to_mark.normalized()
	dash_time = ( to_mark.length() + overshoot ) / move_speed
	assert( dash_dir.y > 0.0 and wind_up_time + dash_time <= duration, "ESFlyAttack: the dash must head down and end within the attack animation" )
	if dash_dir.x != 0:
		enemy.change_dir( signf( dash_dir.x ) )
	if attack_area:
		attack_area.flip( blackboard.dir )
	pass


# it only dashes from above and within reach; otherwise it keeps hovering to line up
func can_attack() -> bool:
	if on_cooldown or blackboard.target == null or blackboard.distance_to_target > attack_range:
		return false
	var offset : Vector2 = blackboard.target.global_position - enemy.global_position
	return offset.y >= min_depth and absf( offset.x ) <= max_reach

func run_cooldown() -> void:
	# connected (not awaited) so the callback is dropped if the enemy is freed first
	get_tree().create_timer( cooldown ).timeout.connect( _end_cooldown )
	pass

func _end_cooldown() -> void:
	on_cooldown = false
	pass
