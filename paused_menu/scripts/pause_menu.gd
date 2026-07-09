extends CanvasLayer
class_name PauseMenu
#region /// on ready variables
@onready var paused_screen: Control = %PausedScreen
@onready var system: Control = %System
@onready var system_menu_button: Button = %SystemMenuButton
@onready var back_to_map_button: Button = %BackToMapButton
@onready var back_to_title_button: Button = %BackToTitleButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var ui_slider: HSlider = %UISlider
#endregion

var player_position : Vector2


func _ready() -> void:
	# grab player
	show_pause_screen()
	system_menu_button.pressed.connect( show_system_menu )
	Audio.setup_button_audio( self )
	set_up_system_menu()
	var player : Node2D = get_tree().get_first_node_in_group( "player" )
	if player:
		player_position = player.global_position
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Audio.ui_cancel()
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	if paused_screen.visible == true:
		if event.is_action_pressed("Right") or event.is_action_pressed("Down"):
			system_menu_button.grab_focus()
			
	pass
	
	
func show_pause_screen() -> void:
	Audio.ui_select()
	paused_screen.visible = true
	system.visible = false
	pass
	
	
func show_system_menu() -> void:
	paused_screen.visible = false
	system.visible = true
	back_to_map_button.grab_focus()
	pass
	

func set_up_system_menu() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear( 2 )
	sfx_slider.value = AudioServer.get_bus_volume_linear( 3 )
	ui_slider.value = AudioServer.get_bus_volume_linear( 4 )
	
	music_slider.value_changed.connect( _on_music_slider_changed )
	sfx_slider.value_changed.connect( _on_sfx_slider_changed )
	ui_slider.value_changed.connect( _on_ui_slider_changed )
	
	back_to_title_button.pressed.connect( _on_back_to_title_pressed )
	back_to_map_button.pressed.connect( show_pause_screen )
	pass
	
func _on_back_to_map_pressed() -> void:
	pass
	
	
func _on_back_to_title_pressed() -> void:
	# free player
	SceneManager.transition_scene( "res://title_screen/title_screen.tscn", "", Vector2.ZERO, "up" )
	get_tree().paused = false
	Messages.back_to_title_screen.emit()
	queue_free()
	pass
	

func _on_music_slider_changed( v : float ) -> void:
	AudioServer.set_bus_volume_linear( 2, v )
	SaveManager.save_configuration()
	pass
	
func _on_sfx_slider_changed( v : float ) -> void:
	AudioServer.set_bus_volume_linear( 3, v )
	Audio.play_spatial_sound( Audio.ui_focus_audio, player_position )
	SaveManager.save_configuration()
	pass
	
func _on_ui_slider_changed( v : float ) -> void:
	AudioServer.set_bus_volume_linear( 4, v )
	Audio.ui_focus_change()
	SaveManager.save_configuration()
	pass
