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
