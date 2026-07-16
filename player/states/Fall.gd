extends PlayerState
class_name PlayerStateFall

@export var coyote_time :  float = 0.125
@export var fall_gravity_multiplier : float = 1.165
@export var jump_buffer_time: float = 0.125

@onready var land_audio: AudioStreamPlayer2D = %LandAudio


var coyote_timer : float = 0
var buffer_timer : float = 0

func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "Jump" )
	player.animation_player.pause()
	player.gravity_multiplier = fall_gravity_multiplier
	# handle jump count
	if player.jump_count == 0:
		player.jump_count = 1
	if player.previous_state == jump or player.previous_state == attack or player.previous_state == ledge_grab :
		coyote_timer = 0
	elif player.previous_state == crouch:
		coyote_timer = 0
		player.jump_count = 1
	else:
		coyote_timer = coyote_time
	pass
	
	
# what happens when exit this state
func exit() -> void:
	player.gravity_multiplier = fall_gravity_multiplier
	buffer_timer = 0
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "attack" ):
		return attack
	if _event.is_action_pressed( "Jump" ):
		if coyote_timer > 0:
			player.jump_count = 0
			return jump
		elif player.jump_count <= 1 and player.double_jump:
			return jump
		else:
			buffer_timer = jump_buffer_time
	return next_state


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	coyote_timer -= _delta
	buffer_timer -= _delta
	set_jump_frame()
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	if ledge_grab.can_grab():
		return ledge_grab
	if player.is_on_floor():
		VisualEffects.land_dust( player.global_position )
		if buffer_timer > 0:
			player.jump_count = 0
			return jump
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
	
func set_jump_frame() -> void:
	var frame : float = remap( player.velocity.y, 0.0, player.max_fall_velocity, 0.5, 1.0  )
	player.animation_player.seek( frame, true )
	pass
	 
	
func play_land_sound() -> void:
	var min_speed: float = 150.0
	var max_speed: float = player.max_fall_velocity
	
	var t = clamp(
		inverse_lerp(min_speed, max_speed, player.landing_speed),
		0.0,
		1.0
	)
	land_audio.volume_db = lerp(-20.0, 0.0, t)
	VisualEffects.camera_shake(lerp(0.0, 0.5, t))
	land_audio.play()
	pass
