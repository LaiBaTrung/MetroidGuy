extends PlayerState
class_name PlayerStateGroundSlam

@export var velocity : float = 400
@export var effect_delay : float = 0.075

var effect_timer : float = 0

const EXPLOSION_AUDIO = preload("uid://unb7yckc0j6q")
const DASH_AUDIO = preload("uid://xgo7mvpjlwus")
const BREAK_WOOD_AUDIO = preload("uid://dn6ssy3xf767j")

@onready var damage_area: DamageArea = %DamageArea
@onready var ground_slam_shape_cast: ShapeCast2D = $"../../GroundSlamShapeCast"
@onready var ground_slam_attack_area: AttackArea = %GroundSlamAttackArea

const HIT_ROCK_LARGE = preload("uid://b50bwfy8sxo3")
const HIT_ROCK_SMALL = preload("uid://4ctd2tg43beb")
const HIT_WOOD_LARGE = preload("uid://ydqj6bls83sk")
const HIT_WOOD_MEDIUM = preload("uid://cbaxccrjliqds")
const HIT_WOOD_SMALL = preload("uid://d08cveykvnhto")


func init() -> void:
	pass
	

# what happens when enter this state
func enter() -> void:
	player.animation_player.play( "ground_slam" )
	player.sprite.tween_color(0.5, Color.PURPLE)
	Audio.play_spatial_sound(DASH_AUDIO, player.global_position, false, true, 0.75 )
	damage_area.start_invulnerable()
	ground_slam_attack_area.set_active()
	pass
	
	
# what happens when exit this state
func exit() -> void:
	
	VisualEffects.camera_shake(10.0)
	VisualEffects.land_dust( player.global_position )
	VisualEffects.hit_dust(player.global_position)
	VisualEffects.hit_particales( ground_slam_shape_cast.global_position, Vector2.UP, HIT_ROCK_LARGE)
	VisualEffects.hit_particales( ground_slam_shape_cast.global_position, Vector2.UP, HIT_ROCK_SMALL)
	Audio.play_spatial_sound(EXPLOSION_AUDIO, player.global_position, false, true, 1.0)
	damage_area.end_invulnerable()
	ground_slam_attack_area.set_active( false )
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	return null


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	check_collisions( _delta )
	effect_timer -= _delta
	if effect_timer < 0:
		effect_timer = effect_delay
		player.sprite.ghost()
	return null


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = 0
	player.velocity = Vector2( 0, velocity )
	if player.is_on_floor():
		if not check_collisions( _delta ):
			return idle
		return idle
	return next_state
	
	
func check_collisions( _delta : float ) -> bool:
	ground_slam_shape_cast.target_position.y = velocity * _delta
	ground_slam_shape_cast.force_shapecast_update()
	if ground_slam_shape_cast.is_colliding():
		for i in ground_slam_shape_cast.get_collision_count():
			var c = ground_slam_shape_cast.get_collider( i )
			var pos : Vector2 = ground_slam_shape_cast.get_collision_point( i )
			
			VisualEffects.hit_dust( pos )
			VisualEffects.camera_shake( 10.0 )
			
			if c.get_parent() is Breakable:
				var b : Breakable = c.get_parent()
				b.queue_free()
				Audio.play_spatial_sound( b.destroy_audio, pos, false, true, 0.75 )
				for p in b.destroy_particles: 
					VisualEffects.hit_particales( pos, Vector2.DOWN, p)
			else:
				c.queue_free()
				VisualEffects.hit_particales( pos, Vector2.DOWN, HIT_WOOD_LARGE)
				VisualEffects.hit_particales( pos, Vector2.UP, HIT_WOOD_SMALL)
				VisualEffects.hit_particales( pos, Vector2.DOWN, HIT_WOOD_MEDIUM)
				Audio.play_spatial_sound( BREAK_WOOD_AUDIO, pos, false, true, 0.75  )
			 
		return true
	return false
