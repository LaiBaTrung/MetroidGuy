extends Camera2D
class_name PlayerCamera

var shake_strength : float = 0.0
@export var shake_decay_rate : float = 5.0
@export var max_shake_offset : float = 20.0
## how fast the camera catches up with the player; 0 locks it to the player
@export var smoothing_speed : float = 10.0

# Smoothing is done here rather than with Camera2D.position_smoothing: the built-in one leaves the
# camera on fractional positions, and with snap_2d_transforms_to_pixel the player and the world then
# round differently and slide a pixel against each other. A whole-pixel camera keeps them together.
const TELEPORT_DISTANCE : float = 160.0   # a jump this big (room change, load) snaps instead of gliding

var _follow_offset : Vector2
var _smoothed : Vector2
var _snap_frames : int = 0


func _ready() -> void:
	VisualEffects.camera_shook.connect( _apply_shake )
	SceneManager.new_scene_ready.connect( _on_new_scene_ready )
	_follow_offset = position
	position_smoothing_enabled = false
	top_level = true
	# the spawner places the player after this runs
	_snap_frames = 3
	_smoothed = _target()
	global_position = _smoothed.round()
	pass


# physics step, not _process: the player only moves on physics ticks (60/s) while frames are drawn
# faster, so a camera moving every drawn frame made the player wobble +-2 px against it
func _physics_process(delta: float) -> void:
	var target : Vector2 = _target()
	if _snap_frames > 0 or smoothing_speed <= 0.0 or target.distance_to( _smoothed ) > TELEPORT_DISTANCE:
		_snap_frames = max( _snap_frames - 1, 0 )
		_smoothed = target
	else:
		_smoothed = _smoothed.lerp( target, 1.0 - exp( -smoothing_speed * delta ) )
	# rounded player position + rounded lag: the player's on-screen pixel then only changes when the lag
	# does, instead of flickering 1 px as two fractional positions round differently (player moves 2.5 px/tick)
	global_position = target.round() + ( _smoothed - target ).round()

	shake_strength = lerp( shake_strength, 0.0, shake_decay_rate * delta )
	if shake_strength < 0.1:
		shake_strength = 0.0
	# whole pixels for the same reason as the camera position
	offset = Vector2(
		randf_range( -shake_strength, shake_strength ),
		randf_range( -shake_strength, shake_strength )
	).round()
	pass


func _target() -> Vector2:
	return get_parent().global_position + _follow_offset


func _apply_shake( strength : float ) -> void:
	shake_strength = min(strength, max_shake_offset)
	pass


# the player is moved and LevelBounds sets new limits a frame later; snap there instead of
# gliding across from the old room while the transition wipe is opening.
# counted in _process (no await), so a camera freed mid-transition leaves nothing pending
func _on_new_scene_ready( _target_name : String, _offset : Vector2 ) -> void:
	_snap_frames = 3
	pass
