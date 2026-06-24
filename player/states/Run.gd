extends PlayerState
class_name PlayerStateRun

func init() -> void:
	pass
	
	
# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "Run" )
	pass
	
	
# what happens when exit this state
func exit() -> void:
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "Jump" ):
		return jump
	return next_state


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	if player.direction.x == 0:
		return idle
	elif player.direction.y > 0.5:
		return crouch
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.move_speed
	if player.is_on_floor() == false:
		return fall
	return next_state
