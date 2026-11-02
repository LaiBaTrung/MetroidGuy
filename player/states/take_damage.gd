extends PlayerState
class_name PlayerStateTakeDamage

@export var move_speed : float = 100
@export var invulnerable_duration : float = 0.5

const HURT_AUDIO = preload("uid://byj4x0u05npvn")

var time : float = 0.0
var dir : float = 1.0

@onready var damage_area: DamageArea = %DamageArea


func init() -> void:
	damage_area.damage_taken.connect( _on_damage_taken )
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "take_damage" )
	time = player.animation_player.current_animation_length
	_play_hit_feedback()
	pass
	
	
# what happens when exit this state
func exit() -> void:
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	time -= _delta
	if time <= 0:
		if player.hp <= 0:
			return death
		# Idle refills jump/dash, so a mid-air hit must not land there
		if not player.is_on_floor():
			return fall
		return idle
	return null


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_speed * dir
	return null


func _on_damage_taken(attack_area : AttackArea) -> void:
	if player.current_state == death:
		return
	# hp is still the pre-hit value here (this runs before player.gd subtracts it)
	if player.current_state == morph_roll and not morph_roll._can_stand() and player.hp > attack_area.damage:
		# standing up in a low tunnel would embed the player: take the hit as a ball
		_play_hit_feedback()
		return
	player.change_state( self )
	if attack_area.global_position.x < player.global_position.x:
		dir = 1.0
	else:
		dir = -1.0
	pass


func _play_hit_feedback() -> void:
	damage_area.make_invulnerable( invulnerable_duration )
	Audio.play_spatial_sound( HURT_AUDIO, player.global_position, false, true, 0.5 )
	player.sprite.tween_color(0.2, Color.RED)
	VisualEffects.camera_shake(2)
	pass
