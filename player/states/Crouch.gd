extends PlayerState
class_name PlayerStateCrouch

@export var deceleration_rate : float = 10.0
func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play("Crouch")
	player.collision_stand.disabled = true	
	player.collision_crouch.disabled = false
	player.da_stand.disabled = true	
	player.da_crouch.disabled = false
	pass
	
	
# what happens when exit this state
func exit() -> void:
	player.collision_stand.set_deferred( "disabled", false )	
	player.collision_crouch.set_deferred("disabled", true)
	player.da_stand.set_deferred("disabled", false)
	player.da_crouch.set_deferred("disabled", true)
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "dash" ) and player.can_dash():
		return dash
	if _event.is_action_pressed( "attack" ):
		return attack
	if _event.is_action_pressed( "Jump" ):
		player.one_way_platform_shapecast.force_shapecast_update()
		if player.one_way_platform_shapecast.is_colliding():
			player.position.y += 4
			return fall
		return jump
	if _event.is_action_pressed( "action" ) and player.can_morph():
		return morph_roll
	return next_state


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x -= player.velocity.x * deceleration_rate * _delta
	if player.is_on_floor() == false:
		return fall
	return next_state
