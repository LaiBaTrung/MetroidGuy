extends PlayerState
class_name PlayerStateMorphRoll


const MORPH_AUDIO = preload("uid://d8itfstwbc8g")
const MORPH_OUT_AUDIO = preload("uid://vq4qjxddmn4w")
const JUMP = preload("uid://b34suoxm14xwv")
const LAND = preload("uid://cwve07jsil8bn")

@export var jump_velocity : float = 400

var on_floor : bool = true

@onready var ball_ray_up: RayCast2D = %BallRayUp
@onready var ball_ray_down: RayCast2D = %BallRayDown


func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "ball" )
	var shape : CapsuleShape2D = player.collision_stand.get_shape() as CapsuleShape2D
	shape.radius = 11.0
	shape.height = 22.0
	
	player.collision_stand.position.y = -11
	player.da_stand.position.y = -11
	
	player.velocity.y -= 100
	
	Audio.play_spatial_sound(MORPH_AUDIO, player.global_position, false, true, 0.5)
	pass
	
	
# what happens when exit this state
func exit() -> void:
	player.animation_player.speed_scale = 1
	var shape : CapsuleShape2D = player.collision_stand.get_shape() as CapsuleShape2D
	shape.radius = 8.0
	shape.height = 46.0
	player.collision_stand.position.y = -23
	player.da_stand.position.y = -23
	Audio.play_spatial_sound(MORPH_OUT_AUDIO, player.global_position, false, true, 0.5)
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed("action"):
		if _can_stand():
			if player.is_on_floor():
				return idle
			return fall
	if _event.is_action_pressed("Jump"):
		if player.is_on_floor():
			if Input.is_action_pressed("Down"):
				player.one_way_platform_shapecast.force_shapecast_update()
				if player.one_way_platform_shapecast.is_colliding():
					player.position.y += 4
					return null
			player.jump_count += 1
			player.velocity.y -= jump_velocity
			Audio.play_spatial_sound( JUMP, player.global_position, false, true, 0.5 )
			VisualEffects.jump_dust( player.global_position )
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	if player.direction.x == 0:
		player.animation_player.speed_scale = 0
	else:
		player.animation_player.speed_scale = 1
	return null


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.move_speed
	if on_floor:
		if not player.is_on_floor():
			on_floor = false
	else:
		if player.is_on_floor():
			on_floor = true
			VisualEffects.land_dust( player.global_position )
			Audio.play_spatial_sound( LAND, player.global_position, false, true, 0.5 )
	return next_state


func _can_stand() -> bool:
	ball_ray_up.force_raycast_update()
	ball_ray_down.force_raycast_update()
	if ball_ray_down.is_colliding() and ball_ray_up.is_colliding():
		return false
	return true
	
