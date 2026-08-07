extends CharacterBody2D
class_name HealthPickup

const HEALTH_UP_AUDIO = preload("uid://bsk8lvguenbwj")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var health_amount : float = 5
@export var bounce_strength : float =  0.75
var bounce_count : int = 8

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect( _on_player_entered )
	pass

func _physics_process( delta: float ) -> void:
	if bounce_count > 0:
		velocity += get_gravity() * delta
		var collision : KinematicCollision2D =  move_and_collide( velocity * delta )
		if collision:
			bounce_count -= 1
			velocity = velocity.bounce( collision.get_normal() ) * bounce_strength
			velocity.x *= bounce_strength
	pass

func _on_player_entered( n : Node2D ) -> void:
	if n is Player:
		n.hp += health_amount
		area_2d.body_entered.disconnect( _on_player_entered )
		Audio.play_spatial_sound( HEALTH_UP_AUDIO,global_position )
		animation_player.play("PickUp")
		await animation_player.animation_finished
		queue_free()
	pass
