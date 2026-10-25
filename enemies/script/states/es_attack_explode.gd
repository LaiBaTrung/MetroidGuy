class_name ESAttackExplode
extends ESAttack

# Self-destruct attack used by the Bomb Monster.
#
# - Entered by DecisionEngineBomb when the PlayerSensor has a target and
#   blackboard.distance_to_target <= attack_range (ESAttack.can_attack()),
#   exactly like LivingArmor's attack.
# - Plays the "attack" animation. The animation's method tracks activate the
#   AttackArea (explosion damage) and play the explosion sound on the detonation frame.
# - When the animation finishes, the enemy removes itself.
#
# Explosion damage = `damage` on the enemy's AttackArea node.
# attack_range, cooldown, move_speed, move_speed_curve, attack_area and
# animation_name are inherited from ESAttack.

@export var explosion_audio : AudioStream
## If true the enemy emits `was_killed` when it self-destructs, so its LootDropper
## drops loot. Off by default: a bomb that blew itself up gives no reward.
@export var drop_loot_on_explode : bool = false

var _self_destructed : bool = false


func enter() -> void:
	super()
	_self_destructed = false
	pass


func physics_update( delta : float ) -> void:
	super( delta )
	# timer / duration come from ESAttack (duration = length of the attack animation)
	if timer >= duration and not _self_destructed:
		_self_destruct()
	pass


# Called from the "attack" animation (method track) on the detonation frame.
func play_explosion_sound() -> void:
	if explosion_audio:
		Audio.play_spatial_sound( explosion_audio, enemy.global_position )
	pass


func _self_destruct() -> void:
	_self_destructed = true
	blackboard.health = 0.0
	if drop_loot_on_explode:
		enemy.was_killed.emit()
	enemy.queue_free()
	pass
