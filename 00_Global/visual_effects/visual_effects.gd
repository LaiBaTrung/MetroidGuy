# VisualEffects 
extends Node

const DUST_EFFECT = preload("uid://c0gjhcjkbqe4b")
const HIT_PARTICLES = preload("uid://cpye0tucas81k")


signal camera_shook( strength : float )

# create dust
# create instance dust
func _create_dust_effect( pos : Vector2 ) -> DustEffect:
	var dust : DustEffect = DUST_EFFECT.instantiate()
	add_child( dust )
	dust.global_position = pos
	return dust
	
# jump dust
func jump_dust( pos : Vector2 ) -> void:
	var dust : DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.JUMP )
	#
	
# land dust
func land_dust ( pos : Vector2 ) -> void:
	var dust : DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.LAND )
	#
	
# hit dust
func hit_dust ( pos : Vector2 ) -> void:
	var dust : DustEffect = _create_dust_effect( pos )
	dust.start( DustEffect.TYPE.HIT )
	#
	
func hit_particales( pos : Vector2, dir : Vector2 ,settings : HitParticleSettings) -> void:
	var p : HitParticles = HIT_PARTICLES.instantiate()
	add_child( p )
	p.global_position = pos
	p.start( dir, settings )
	pass
	
	
func camera_shake( strength : float = 1.0 ) -> void:
	camera_shook.emit( strength )
	pass


# brief near-freeze on a hit; timed in real seconds (ignores time_scale) so it always ends,
# and counted so an overlapping hit never ends another one early
const HIT_STOP_TIME_SCALE : float = 0.0
var _hit_stops : int = 0

func hit_stop( duration : float = 0.05 ) -> void:
	_hit_stops += 1
	Engine.time_scale = HIT_STOP_TIME_SCALE
	await get_tree().create_timer( duration, true, false, true ).timeout
	_hit_stops -= 1
	assert( _hit_stops >= 0, "VisualEffects: more hit stops ended than started" )
	if _hit_stops == 0:
		Engine.time_scale = 1.0
	pass
