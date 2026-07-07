@icon( "res://general/icons/player_spawn.svg" )
extends Node2D
class_name PlayerSpawn




func _ready() -> void:
	visible = false
	await get_tree().process_frame
	
	var player : Player = load( "uid://dwjayvisjl5xx" ).instantiate()
	get_tree().root.add_child( player )
	
	player.global_position = self.global_position
	
	
	pass
