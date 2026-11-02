extends PlayerState
class_name PlayerStateAttack

const AUDIO_ATTACK = preload("uid://c0t0vjc3ofap")
# the crouch attack frames (37-42) hold the sword 10 px lower than the standing ones
const CROUCH_ATTACK_DROP : float = 10.0

@export var combo_time_window : float = 0.2
@export var speed : float = 150
var timer : float = 0
var combo : int = 0
var crouching : bool = false
var attack_sprite_y : float
var attack_area_y : float

@onready var attack_sprite_2d: Sprite2D = %AttackSprite2D


func init() -> void:
	attack_sprite_2d.visible = false
	attack_sprite_y = attack_sprite_2d.position.y
	attack_area_y = player.attack_area.position.y
	pass


# what happens when enter this state
func enter() -> void:
	crouching = player.previous_state == crouch and player.is_on_floor()
	var drop : float = CROUCH_ATTACK_DROP if crouching else 0.0
	attack_sprite_2d.position.y = attack_sprite_y + drop
	player.attack_area.position.y = attack_area_y + drop
	if crouching:
		# Crouch.exit() queued deferred calls that restore the standing shapes; queue ours after them
		player.collision_stand.set_deferred( "disabled", true )
		player.collision_crouch.set_deferred( "disabled", false )
		player.da_stand.set_deferred( "disabled", true )
		player.da_crouch.set_deferred( "disabled", false )
	do_attack()
	player.animation_player.animation_finished.connect( _on_animation_finished )
	pass
	
	
# what happens when exit this state
func exit() -> void:
	timer = 0
	combo = 0
	player.animation_player.animation_finished.disconnect( _on_animation_finished )
	if crouching and next_state != crouch:
		# Crouch.enter() sets its own shapes, so only restore standing ones when leaving elsewhere
		player.collision_stand.set_deferred( "disabled", false )
		player.collision_crouch.set_deferred( "disabled", true )
		player.da_stand.set_deferred( "disabled", false )
		player.da_crouch.set_deferred( "disabled", true )
	crouching = false
	attack_sprite_2d.position.y = attack_sprite_y
	player.attack_area.position.y = attack_area_y
	next_state = null
	attack_sprite_2d.visible = false

	pass  
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "attack" ):
		timer = combo_time_window
	if _event.is_action_pressed( "dash" ) and player.can_dash():
		return dash
	# in the air only the double jump can cancel an attack (jump_count == 1: first jump used, second free)
	if _event.is_action_pressed( "Jump" ) and ( player.is_on_floor() or ( player.double_jump and player.jump_count == 1 ) ):
		return jump
	if _event.is_action_pressed( "action" ) and player.can_morph():
		return morph_roll
	return null


# what happens each progress tick in this state
func process(delta: float) -> PlayerState:
	timer -= delta
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	if crouching:
		player.velocity.x = 0
	else:
		player.velocity.x = player.direction.x * speed
	return null


func do_attack() -> void:
	var anim_name : String = "attack"
	if combo > 0:
		anim_name = "attack_2"
	if crouching:
		anim_name = "crouch_" + anim_name
	player.animation_player.play( anim_name )
	player.attack_area.activate()
	Audio.play_spatial_sound( AUDIO_ATTACK, player.global_position, false, true, 0.25 )
	pass
	
func _end_attack() -> void:
	if timer > 0:
		combo = wrapi( combo + 1, 0, 2 )
		do_attack()
	else:
		if crouching and player.direction.y > 0.5:
			next_state = crouch
		elif player.is_on_floor():
			next_state = idle
		else:
			next_state = fall
	pass
	
	
func _on_animation_finished( _anim_name : String ) -> void:
	_end_attack()
	pass
	
	
	
