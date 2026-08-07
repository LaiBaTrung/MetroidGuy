extends PlayerState
class_name PlayerStateDeath

const DEATH_AUDIO = preload("uid://dp1dhdjwuyoao")
@onready var damage_area: DamageArea = %DamageArea




# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "death" )
	Audio.play_spatial_sound( DEATH_AUDIO, player.global_position, true )
	Audio.play_music( null )
	damage_area.monitorable = false
	await player.animation_player.animation_finished
	PlayerHud.show_game_over()
	pass
	
	
# what happens when exit this state
func exit() -> void:
	damage_area.monitorable = true
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	return null


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = 0
	return null
