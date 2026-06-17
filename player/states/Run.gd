extends PlayerState
class_name PlayerStateRun

func init() -> void:
	pass
	
	
# what happens when enter this state
func enter() -> void:	
	pass
	
	
# what happens when exit this state
func exit() -> void:
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	return next_state


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	return next_state
