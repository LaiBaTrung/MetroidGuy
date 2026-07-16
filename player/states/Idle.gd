extends PlayerState
class_name PlayerStateIdle



func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "Idle" )
	player.jump_count = 0
	pass
	
	
# what happens when exit this state
func exit() -> void:
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "attack" ):
		return attack
	if _event.is_action_pressed( "Jump" ):
		return jump
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	if player.direction.x != 0:
		return run
	elif player.direction.y > 0.5:
		return crouch
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = 0
	if player.is_on_floor() == false:
		return fall
	return next_state
