extends PlayerState
class_name PlayerStateJump

@export var jump_velocity : float = 480.0

@onready var jump_audio: AudioStreamPlayer2D = %JumpAudio

func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	if player.is_on_floor():
		VisualEffects.jump_dust( player.global_position )
	else:
		VisualEffects.hit_dust( player.global_position )
	player.animation_player.play( "Jump" )
	player.animation_player.pause()
	do_jump()
	# check if this is a jump buffer
	# if it is, handle jump button release 
	if player.previous_state == fall and not Input.is_action_pressed( "Jump" ):
		await get_tree().physics_frame
		player.velocity.y *= 0.5
		player.change_state( fall )
		pass
		
	pass
	
	
# what happens when exit this state
func exit() -> void:
	#player.add_debug_indicator( Color.YELLOW )
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( event : InputEvent ) -> PlayerState:
	if event.is_action_pressed( "attack" ):
		return attack
	if event.is_action_released( "Jump" ):
		return fall
	return next_state


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	set_jump_frame()
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
	
func do_jump() -> void:
	if player.ledge_grab_jump:
		player.ledge_grab_jump = false
		player.velocity.y = -jump_velocity
		jump_audio.play()
		return
	if player.jump_count > 0:
		if player.double_jump == false:
			return
		elif player.jump_count > 1:
			return
	player.jump_count += 1
	player.velocity.y = -jump_velocity
	jump_audio.play()
	pass
	
	
func set_jump_frame() -> void:
	var frame : float = remap( player.velocity.y, -jump_velocity, 0.0, 0.0, 0.5  )
	player.animation_player.seek( frame, true )
	pass
	
	
