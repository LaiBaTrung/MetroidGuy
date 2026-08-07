extends PlayerState
class_name PlayerStateDash

const DASH_AUDIO = preload("uid://xgo7mvpjlwus")

@export var duration : float = 0.25
@export var speed : float = 300.0
@export var effect_delay : float = 0.05

var dir : float = 1.0
var time : float = 0.0      
var effect_time : float = 0.0

@onready var damage_area: DamageArea = %DamageArea


func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "dash" )
	time = duration
	effect_time = 0.0
	get_dash_direction()
	damage_area.make_invulnerable( duration )
	Audio.play_spatial_sound( DASH_AUDIO, player.global_position, false, true, 0.75 )
	player.gravity_multiplier = 0.0
	player.velocity.y = 0.0
	
	player.dash_count += 1
	player.sprite.tween_color()
	
	pass
	
	
# what happens when exit this state
func exit() -> void:
	player.gravity_multiplier = 1.0
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "action" ) and player.can_morph():
		return morph_roll
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	time -= _delta
	if time <= 0:
		if player.is_on_floor():
			return idle
		else:
			return fall
			
	effect_time -= _delta
	if effect_time < 0:
		effect_time = effect_delay
		player.sprite.ghost()
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	if ledge_grab.can_grab():
		return ledge_grab
	player.velocity.x = ( speed * (time / duration ) + speed ) * dir
	return next_state
	
	
func get_dash_direction()-> void:
	dir = 1.0
	if player.sprite.flip_h == true:
		dir = -1.0
	pass
