extends PlayerState
class_name PlayerStateLedgeGrab


@onready var ledge_grab_miss: RayCast2D = %Ledge_grab_miss
@onready var ledge_grab_hit: RayCast2D = %Ledge_grab_hit

var grab_cooldown : float = 0.0


func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.ledge_grab_jump = true
	player.dash_count = 0
	player.animation_player.play( "ledge_grab" )
	player.velocity = Vector2.ZERO
	player.gravity_multiplier = 0
	player.direction_locked = true
	pass
	
	
# what happens when exit this state
func exit() -> void:
	player.gravity_multiplier = 1.0
	player.direction_locked = false
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "Jump" ):
		player.velocity.x = -player.facing_direction * 120
		return jump
	if _event.is_action_pressed( "Down" ):
		grab_cooldown = Time.get_ticks_msec() + 300
		return fall
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	if grab_cooldown > 0:
		grab_cooldown -= _delta
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity = Vector2.ZERO
	return null
	
	
func can_grab() -> bool:
	return(
		Time.get_ticks_msec() >= grab_cooldown and
		ledge_grab_hit.is_colliding() and
		!ledge_grab_miss.is_colliding() and
		player.velocity.y > 0 and
		!player.is_on_floor()
	)
	
	
func flip(dir) -> void:
	ledge_grab_hit.position.x = abs(ledge_grab_hit.position.x) * dir
	ledge_grab_miss.position.x = abs(ledge_grab_miss.position.x) * dir
	ledge_grab_hit.target_position.x = abs(ledge_grab_hit.target_position.x) * dir
	ledge_grab_miss.target_position.x = abs(ledge_grab_miss.target_position.x) * dir
	pass
