@icon("res://general/icons/player_sensor.svg")
extends Area2D
class_name PlayerSensor

signal player_entered
signal player_exited
signal started_searching


@export var search_duration : float = 2
@export var use_audio_sensor : bool = true
@export var audio_detect_distance : float = 450
@export var min_audio_sense : float = 0.2


var enemy : Enemy
var timer : float
var player_inside : bool = false
var found_player : bool = false

func _ready() -> void:
	set_collision_mask_value( 1, false )
	set_collision_layer_value( 1, false )
	if owner is Enemy:
		enemy = owner
		set_collision_mask_value( 5, true )
		if use_audio_sensor:
			Audio.player_made_sound.connect( _on_player_sound )
		body_entered.connect( _on_body_entered )
		body_exited.connect( _on_body_exited )
		enemy.direction_changed.connect( _on_direction_changed )
	pass

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			enemy.blackboard.target = body
			timer = 0
			return

	if timer > 0:
		timer -= delta

		if timer <= 0:
			player_exited.emit()
			enemy.blackboard.target = null
		pass
	
	
func _on_body_entered( body ) -> void:
	if body.is_in_group("Player"):
		player_inside = true
		player_entered.emit()
		enemy.blackboard.target = body
		timer = 0
	pass
	
	
func _on_body_exited( body ) -> void:
	if body.is_in_group("Player"):
		player_inside = false
	started_searching.emit()
	timer = search_duration
	pass
	
	
func _on_direction_changed( dir : float ) -> void:
	if dir < 0:
		scale.x = -1
	elif dir > 0:
		scale.x = 1
	pass

func _on_player_sound( pos : Vector2, volume : float ) -> void:
	var sound_distance : float = global_position.distance_to( pos )
	var d : float = clamp(1 - sound_distance / audio_detect_distance, 0.0, 1.0) * 2 
	var perceived_vol : float = volume * d
	if perceived_vol >= min_audio_sense:
		timer = search_duration
		enemy.blackboard.target = get_tree().get_first_node_in_group("Player")
	pass
