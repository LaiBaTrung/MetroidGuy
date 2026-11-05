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
@onready var map_button: Button = %MapButton
@onready var map: Control = %Map
@onready var player_indicator: Control = %PlayerIndicator
#endregion

# 1.0: the game renders at 500x260 (stretch "viewport"), so below 1x the 1 px map lines break up
const ZOOM_MIN : float = 1.0
const ZOOM_MAX : float = 2.5
const ZOOM_STEP : float = 0.1
const PAN_SPEED : float = 150

var player_position : Vector2
var map_open : bool = false
var map_home_position : Vector2


func _ready() -> void:
	show_pause_screen()
	system_menu_button.pressed.connect( show_system_menu )
	map_button.pressed.connect( open_map )
	map_home_position = map.position
	Audio.setup_button_audio( self )
	set_up_system_menu()
	var player : Node2D = get_tree().get_first_node_in_group( "Player" )
	if player:
		player_position = player.global_position
	pass
	

func _unhandled_input(event: InputEvent) -> void:
	if paused_screen.visible == true and event.is_action_pressed("map"):
		get_viewport().set_input_as_handled()
		Audio.ui_select()
		open_map()
		return
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
	

#region /// map
# while the map is open it owns all input, so Esc / arrows never reach the menu below
func _input( event : InputEvent ) -> void:
	if not map_open:
		return
	if event.is_action_pressed( "map" ) or event.is_action_pressed( "pause" ) or event.is_action_pressed( "ui_cancel" ):
		close_map()
	elif event.is_action_pressed( "zoom_in" ):
		zoom_map( ZOOM_STEP, view_center() )
	elif event.is_action_pressed( "zoom_out" ):
		zoom_map( -ZOOM_STEP, view_center() )
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_map( ZOOM_STEP, event.position - paused_screen.position )
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_map( -ZOOM_STEP, event.position - paused_screen.position )
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		pan_map( event.relative )
	get_viewport().set_input_as_handled()
	pass


func _process( delta : float ) -> void:
	if not map_open:
		return
	var dir : Vector2 = Input.get_vector( "Left", "Right", "Up", "Down" )
	if dir != Vector2.ZERO:
		pan_map( -dir * PAN_SPEED * delta )
	pass


func open_map() -> void:
	map_open = true
	# shortcut: re-shows every PausedScreen child on close, track visibility if one is ever meant to stay hidden
	for c in paused_screen.get_children():
		c.visible = c == map
	get_viewport().gui_release_focus()
	map.scale = Vector2.ONE
	map.position = view_center() - player_indicator.position
	clamp_map()
	pass


func close_map() -> void:
	map_open = false
	map.scale = Vector2.ONE
	map.position = map_home_position
	for c in paused_screen.get_children():
		c.visible = true
	Audio.ui_cancel()
	map_button.grab_focus()
	pass


func view_center() -> Vector2:
	return paused_screen.size / 2


func pan_map( amount : Vector2 ) -> void:
	map.position += amount
	clamp_map()
	pass


# zooms around pivot (PausedScreen coords) so the point under it stays put
func zoom_map( step : float, pivot : Vector2 ) -> void:
	var old_zoom : float = map.scale.x
	var new_zoom : float = clampf( snappedf( old_zoom + step, ZOOM_STEP ), ZOOM_MIN, ZOOM_MAX )
	var local_pivot : Vector2 = ( pivot - map.position ) / old_zoom
	map.position = pivot - local_pivot * new_zoom
	map.scale = Vector2( new_zoom, new_zoom )
	assert( ( ( pivot - map.position ) / new_zoom ).is_equal_approx( local_pivot ) )
	clamp_map()
	pass


# keeps the view centre inside the bounds of the discovered (visible) map nodes
func clamp_map() -> void:
	var bounds : Rect2
	var found : bool = false
	for c in map.get_children():
		if c is MapNode and c.visible:
			var r : Rect2 = Rect2( c.position, c.size )
			bounds = bounds.merge( r ) if found else r
			found = true
	if not found:
		return
	var center : Vector2 = view_center()
	var zoom : float = map.scale.x
	map.position = map.position.clamp( center - bounds.end * zoom, center - bounds.position * zoom )
	pass
#endregion
