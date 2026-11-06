extends CanvasLayer
class_name PauseMenu
#region /// on ready variables
@onready var paused_screen: Control = %PausedScreen
@onready var system: Control = %System
@onready var back_to_title_button: Button = %BackToTitleButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var ui_slider: HSlider = %UISlider
@onready var map: Control = %Map
@onready var player_indicator: Control = %PlayerIndicator
@onready var abilities_tab: Control = %AbilitiesTab
@onready var map_tab: Control = %MapTab
@onready var pages_tab: Control = %PagesTab
@onready var abilities_list: AbilitiesList = %AbilitiesList
@onready var hints_left: HBoxContainer = %HintsLeft
@onready var hints: HBoxContainer = %Hints
@onready var heart_row: HBoxContainer = %HeartRow
@onready var hp_value: Label = %HPValue
@onready var hearts_value: Label = %HeartsValue
@onready var pages_value: Label = %PagesValue
@onready var region_value: Label = %RegionValue
@onready var explored_value: Label = %ExploredValue
@onready var last_save_label: Label = %LastSaveLabel
@onready var region_list: VBoxContainer = %RegionList
@onready var map_region_title: Label = %MapRegionTitle
@onready var map_explored: Label = %MapExplored
@onready var page_grid: GridContainer = %PageGrid
@onready var pages_found: Label = %PagesFound
@onready var tab_buttons: Array[Button] = [ %TabMap, %TabAbilities, %TabPages, %TabSystem ]
#endregion

# tab order matches the tab buttons left to right and the icon columns in ui_icons.png
enum Tab { MAP, ABILITIES, PAGES, SYSTEM }

# 1.0: the game renders at 500x260 (stretch "viewport"), so below 1x the 1 px map lines break up
const ZOOM_MIN : float = 1.0
const ZOOM_MAX : float = 2.5
const ZOOM_STEP : float = 0.1
const PAN_SPEED : float = 150

const ICONS : Texture2D = preload( "res://paused_menu/sprites/ui_icons.png" )
const ICON_CELL : int = 12
const PAGE_SLOT_EMPTY : Texture2D = preload( "res://paused_menu/sprites/page_slot_empty.png" )
# shortcut: region names are hard-coded per level folder, add a line when a new region folder is made (e.g. 02_scriptorium)
const REGION_NAMES : Dictionary = {
	"00_forest": "Blotted Wood",
	"01_dungeon(under)": "Undercroft",
}
const HP_PER_HEART : float = 5.0
const BASE_MAX_HP : float = 20.0
const HEART_UPGRADES : int = 4
const PAGE_COUNT : int = 12
const HINT_GAP : int = 6
const HINTS : Dictionary = {
	Tab.MAP: [ [ "Q/E", "Zoom" ], [ "Esc", "Close" ] ],
	Tab.ABILITIES: [ [ "Esc", "Close the book" ] ],
	Tab.PAGES: [ [ "Esc", "Close the book" ] ],
	Tab.SYSTEM: [ [ "Enter", "Select" ], [ "Esc", "Close" ] ],
}

var player_position : Vector2
var map_open : bool = false
var map_home_position : Vector2
var current_tab : int = Tab.ABILITIES


func _ready() -> void:
	map_home_position = map.position
	Audio.setup_button_audio( self )
	set_up_system_menu()
	assert( tab_buttons.size() == Tab.size(), "PauseMenu: one tab button per Tab page" )
	assert( region_of( "res://level/01_dungeon(under)/05.tscn" ) == "Undercroft" and region_of( "" ) == "-", "PauseMenu: region_of" )
	for i in tab_buttons.size():
		tab_buttons[i].pressed.connect( show_tab.bind( i ) )
	var player : Node2D = get_tree().get_first_node_in_group( "Player" )
	if player:
		player_position = player.global_position
	fill_hero_sheet()
	fill_map_page()
	fill_pages()
	_set_hints( hints_left, [ [ "Tab", "Next tab" ] ] )
	show_tab( Tab.ABILITIES )
	pass


func _unhandled_input( event : InputEvent ) -> void:
	if event.is_action_pressed( "pause" ):
		close_menu()
	elif event.is_action_pressed( "map" ):
		get_viewport().set_input_as_handled()
		Audio.ui_select()
		show_tab( Tab.MAP )
	pass


# runs before the GUI, so Tab / Shift+Tab switch tabs instead of moving focus
func _input( event : InputEvent ) -> void:
	if event.is_action_pressed( "ui_focus_prev" ) or event.is_action_pressed( "ui_focus_next" ):
		# Shift+Tab also matches ui_focus_next, so check prev first
		var step : int = -1 if event.is_action_pressed( "ui_focus_prev" ) else 1
		Audio.ui_focus_change()
		show_tab( wrapi( current_tab + step, 0, tab_buttons.size() ) )
		get_viewport().set_input_as_handled()
		return
	_map_input( event )
	pass


func close_menu() -> void:
	Audio.ui_cancel()
	get_viewport().set_input_as_handled()
	get_tree().paused = false
	queue_free()
	pass


#region /// tabs
func show_tab( tab : int ) -> void:
	current_tab = tab
	map_tab.visible = tab == Tab.MAP
	abilities_tab.visible = tab == Tab.ABILITIES
	pages_tab.visible = tab == Tab.PAGES
	system.visible = tab == Tab.SYSTEM
	for i in tab_buttons.size():
		var selected : bool = i == tab
		tab_buttons[i].set_pressed_no_signal( selected )
		tab_buttons[i].icon = _icon( i + ( 4 if selected else 0 ), 0 )
		tab_buttons[i].get_node( "Point" ).visible = selected
	_set_hints( hints, HINTS[ tab ] )
	if tab == Tab.MAP:
		_enter_map_mode()
	else:
		_exit_map_mode()
	match tab:
		Tab.ABILITIES:
			abilities_list.focus_first()
		Tab.SYSTEM:
			music_slider.grab_focus()
		_:
			get_viewport().gui_release_focus()
	pass


# one key cap + one label per pair, e.g. [ "Esc", "Close" ]
func _set_hints( box : HBoxContainer, pairs : Array ) -> void:
	for c in box.get_children():
		box.remove_child( c )
		c.queue_free()
	for pair in pairs:
		if box.get_child_count() > 0:
			var gap : Control = Control.new()
			gap.custom_minimum_size = Vector2( HINT_GAP, 0 )
			box.add_child( gap )
		var key : Label = Label.new()
		key.theme_type_variation = &"KeyCap"
		key.text = pair[ 0 ]
		var text : Label = Label.new()
		text.theme_type_variation = &"BookLight"
		text.text = pair[ 1 ]
		box.add_child( key )
		box.add_child( text )
	pass


func _icon( col : int, row : int ) -> AtlasTexture:
	var t : AtlasTexture = AtlasTexture.new()
	t.atlas = ICONS
	t.region = Rect2( col * ICON_CELL, row * ICON_CELL, ICON_CELL, ICON_CELL )
	return t
#endregion


#region /// pages of the book
func fill_hero_sheet() -> void:
	var player : Player = get_tree().get_first_node_in_group( "Player" )
	if not player:
		return
	for c in heart_row.get_children():
		c.queue_free()
	var hearts : int = ceili( player.max_hp / HP_PER_HEART )
	var full : int = ceili( player.hp / HP_PER_HEART )
	for i in hearts:
		var heart : TextureRect = TextureRect.new()
		heart.texture = _icon( 0 if i < full else 1, 1 )
		heart_row.add_child( heart )
	hp_value.text = "%d / %d" % [ int( player.hp ), int( player.max_hp ) ]
	var upgrades : int = clampi( int( ( player.max_hp - BASE_MAX_HP ) / HP_PER_HEART ), 0, HEART_UPGRADES )
	hearts_value.text = "%d / %d" % [ upgrades, HEART_UPGRADES ]
	pages_value.text = "%d / %d" % [ found_page_count(), PAGE_COUNT ]
	region_value.text = region_of( SceneManager.current_scene_uid )
	explored_value.text = "%d / %d rooms" % [ discovered_map_nodes().size(), map_nodes().size() ]
	last_save_label.text = "Last save: %s" % region_of( SaveManager.save_data.get( "scene_path", "" ) )
	pass


func fill_map_page() -> void:
	map_region_title.text = region_of( SceneManager.current_scene_uid )
	map_explored.text = "Explored %d / %d" % [ discovered_map_nodes().size(), map_nodes().size() ]
	# region -> [ discovered, total ], counting only map nodes linked to a room
	var counts : Dictionary = {}
	for n in map_nodes():
		if n.linked_scene.is_empty():
			continue
		var region : String = region_of( n.linked_scene )
		if not counts.has( region ):
			counts[ region ] = [ 0, 0 ]
		counts[ region ][ 1 ] += 1
		if SaveManager.is_area_discovered( n.linked_scene ):
			counts[ region ][ 0 ] += 1
	for c in region_list.get_children():
		c.queue_free()
	for region in counts:
		var found : int = counts[ region ][ 0 ]
		var row : HBoxContainer = HBoxContainer.new()
		var name_label : Label = Label.new()
		name_label.text = region
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var count_label : Label = Label.new()
		count_label.text = "%d / %d" % [ found, counts[ region ][ 1 ] ]
		if found == 0:
			name_label.theme_type_variation = &"BookFaint"
			count_label.theme_type_variation = &"BookFaint"
		row.add_child( name_label )
		row.add_child( count_label )
		region_list.add_child( row )
	pass


func fill_pages() -> void:
	for c in page_grid.get_children():
		c.queue_free()
	for i in PAGE_COUNT:
		var slot : TextureRect = TextureRect.new()
		slot.texture = PAGE_SLOT_EMPTY
		page_grid.add_child( slot )
	pages_found.text = "%d of %d found" % [ found_page_count(), PAGE_COUNT ]
	pass


# lore pages are stored as "page_<nn>" keys once page pickups exist
func found_page_count() -> int:
	var n : int = 0
	for key in SaveManager.persitent_data:
		if str( key ).begins_with( "page_" ):
			n += 1
	return n


func region_of( scene : String ) -> String:
	if scene.is_empty():
		return "-"
	var path : String = ResourceUID.uid_to_path( scene ) if scene.begins_with( "uid://" ) else scene
	for folder in REGION_NAMES:
		if path.contains( "/%s/" % folder ):
			return REGION_NAMES[ folder ]
	return "Unknown"


# shortcut: also counts the placeholder map nodes (22, not the planned 25 rooms), count linked nodes once every room has a scene
func map_nodes() -> Array[ MapNode ]:
	var nodes : Array[ MapNode ] = []
	for c in map.get_children():
		if c is MapNode:
			nodes.append( c )
	return nodes


func discovered_map_nodes() -> Array[ MapNode ]:
	var nodes : Array[ MapNode ] = []
	for n in map_nodes():
		if not n.linked_scene.is_empty() and SaveManager.is_area_discovered( n.linked_scene ):
			nodes.append( n )
	return nodes
#endregion


#region /// system
func set_up_system_menu() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear( 2 )
	sfx_slider.value = AudioServer.get_bus_volume_linear( 3 )
	ui_slider.value = AudioServer.get_bus_volume_linear( 4 )

	music_slider.value_changed.connect( _on_music_slider_changed )
	sfx_slider.value_changed.connect( _on_sfx_slider_changed )
	ui_slider.value_changed.connect( _on_ui_slider_changed )
	for s in [ music_slider, sfx_slider, ui_slider ]:
		s.focus_entered.connect( _mark_slider_row.bind( s, true ) )
		s.focus_exited.connect( _mark_slider_row.bind( s, false ) )

	back_to_title_button.pressed.connect( _on_back_to_title_pressed )
	pass


# the focused slider's label turns crimson, the slider itself has no focus frame
func _mark_slider_row( slider : HSlider, focused : bool ) -> void:
	var label : Label = slider.get_parent().get_child( 0 ) as Label
	if label:
		label.theme_type_variation = &"BookTitle" if focused else &""
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
#endregion


#region /// map
# Called by the player when the map key opens the menu.
func open_map() -> void:
	show_tab( Tab.MAP )
	pass


# while the Map tab is open it owns all input, so Esc / arrows never reach the rest of the menu
func _map_input( event : InputEvent ) -> void:
	if not map_open:
		return
	if event.is_action_pressed( "map" ) or event.is_action_pressed( "pause" ) or event.is_action_pressed( "ui_cancel" ):
		close_menu()
		return
	elif event.is_action_pressed( "zoom_in" ):
		zoom_map( ZOOM_STEP, view_center() )
	elif event.is_action_pressed( "zoom_out" ):
		zoom_map( -ZOOM_STEP, view_center() )
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_map( ZOOM_STEP, event.position - paused_screen.global_position )
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_map( -ZOOM_STEP, event.position - paused_screen.global_position )
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		pan_map( event.relative )
	elif event is InputEventMouseButton and paused_screen.get_global_rect().has_point( event.position ) == false:
		# clicks outside the map still reach the tab buttons
		return
	get_viewport().set_input_as_handled()
	pass


func _process( delta : float ) -> void:
	if not map_open:
		return
	var dir : Vector2 = Input.get_vector( "Left", "Right", "Up", "Down" )
	if dir != Vector2.ZERO:
		pan_map( -dir * PAN_SPEED * delta )
	pass


func _enter_map_mode() -> void:
	map_open = true
	get_viewport().gui_release_focus()
	map.scale = Vector2.ONE
	map.position = view_center() - player_indicator.position
	clamp_map()
	pass


func _exit_map_mode() -> void:
	map_open = false
	map.scale = Vector2.ONE
	map.position = map_home_position
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
