extends PlayerState
class_name PlayerStateJump

@export var jump_velocity : float = 480.0

func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "Jump" )
	player.animation_player.pause()
	#player.add_debug_indicator( Color.GREEN )
	player.velocity.y =- jump_velocity
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
	if event.is_action_released( "Jump" ):
		player.velocity.y *= 0.5
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
	

func set_jump_frame() -> void:
	var frame : float = remap( player.velocity.y, -jump_velocity, 0.0, 0.0, 0.5  )
	player.animation_player.seek( frame, true )
	pass
