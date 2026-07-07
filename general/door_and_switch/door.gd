@icon( "res://general/icons/door.svg" )
@tool
extends Node2D
class_name Door
const DOOR_CRASH_AUDIO = preload("uid://x82rul1f4tfl")
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	for c in get_children():
		if c is Switch:
			c.activated.connect( _on_switch_ativated )
			if c.is_open == true:
				_on_switch_is_opened()
	pass
	
	
func _on_switch_ativated() -> void:
	Audio.play_spatial_sound( DOOR_CRASH_AUDIO, global_position )
	animation_player.play("open")
	pass
	
	
func _on_switch_is_opened() -> void:
	animation_player.play("opened")
	pass
	
	
func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_switch() == false:
		return [ "Requires a Switch node." ]
	return []
	
	
func _check_for_switch() -> bool:
	for c in get_children():
		if c is Switch:
			return true
	return false 
