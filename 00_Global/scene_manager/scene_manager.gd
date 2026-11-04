extends CanvasLayer

signal load_scene_started
signal load_scene_finished
signal new_scene_ready( target_name : String, offset : Vector2 )
signal scene_entered ( uid : String )

@onready var fade: Control = $Fade

var current_scene_uid : String

# rooms reachable from the current one, loading on a background thread so a room change
# does not stall on disk while the screen is covered (forest 02 took ~1 s to load)
var _preloading : Array[ String ] = []

func _ready()-> void:
	fade.visible = false
	await get_tree().process_frame
	load_scene_finished.emit()
	var current_scene : String = get_tree().current_scene.scene_file_path
	current_scene_uid = ResourceUID.path_to_uid(current_scene)
	scene_entered.emit( current_scene_uid )
	_preload_neighbours()
	pass


func transition_scene( 
	new_scene : String, 
	target_area : String, 
	player_offset : Vector2, 
	dir : String  ) -> void:
	
	get_tree().paused = true
	
	var fade_pos : Vector2 = get_fade_pos( dir )
	
	fade.visible = true
	
	load_scene_started.emit()

	# no-op when the room is already preloading; otherwise it loads during the fade
	_request_load( new_scene )

	await fade_screen( fade_pos, Vector2.ZERO )

	var packed : PackedScene = await _get_loaded( new_scene )
	if packed:
		get_tree().change_scene_to_packed( packed )
	else:
		get_tree().change_scene_to_file( new_scene )

	current_scene_uid = ResourceUID.path_to_uid( new_scene )
	scene_entered.emit( current_scene_uid )
	
	await get_tree().scene_changed
	
	new_scene_ready.emit( target_area, player_offset )
	
	await get_tree().process_frame
	
	await fade_screen( Vector2.ZERO, -fade_pos  )
	
	fade.visible = false
	
	get_tree().paused = false

	load_scene_finished.emit()
	_preload_neighbours()
	pass


func _request_load( path : String ) -> void:
	if _preloading.has( path ):
		return
	if ResourceLoader.load_threaded_request( path ) == OK:
		_preloading.append( path )
	pass


# waits for a background load; null means "not preloaded or failed", so the caller loads it directly
func _get_loaded( path : String ) -> PackedScene:
	if not _preloading.has( path ):
		return null
	while ResourceLoader.load_threaded_get_status( path ) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	var packed : PackedScene = null
	if ResourceLoader.load_threaded_get_status( path ) == ResourceLoader.THREAD_LOAD_LOADED:
		packed = ResourceLoader.load_threaded_get( path ) as PackedScene
	_preloading.erase( path )
	return packed


func _preload_neighbours() -> void:
	var scene : Node = get_tree().current_scene
	if not scene:
		return
	var targets : Array[ String ] = []
	for c in scene.get_children():
		if c is LevelTransition and c.target_level != "":
			targets.append( c.target_level )
	# hand back finished loads we no longer need so they can be freed; ones still loading are collected next time
	for p in _preloading.duplicate():
		if targets.has( p ):
			continue
		if ResourceLoader.load_threaded_get_status( p ) != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			ResourceLoader.load_threaded_get( p )
			_preloading.erase( p )
	for t in targets:
		_request_load( t )
	pass

func fade_screen(from : Vector2, to : Vector2)-> Signal:
	fade.position = from
	var tween : Tween = create_tween()
	tween.tween_property( fade, "position", to, 0.2 )
	return tween.finished
	
func get_fade_pos( dir : String ) -> Vector2:
		var pos : Vector2 = Vector2 (500 * 2, 280 * 2)
		match dir:
			"left":
				pos *= Vector2( -1, 0 )
			"right":
				pos *= Vector2( 1, 0  )
			"up":
				pos *= Vector2( 0, -1 )
			"down":
				pos *= Vector2( 0, 1  )
				
		return pos
