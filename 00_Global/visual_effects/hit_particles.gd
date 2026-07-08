extends GPUParticles2D
class_name HitParticles




func start( dir : Vector2, setting : HitParticleSettings ) -> void:
	if setting:
		amount  = setting.count
		modulate	 = setting.color
		texture = setting.texture
	process_material.direction = Vector3( dir.x, dir.y, 0 )  
	emitting = true
	await finished
	queue_free()
	pass
