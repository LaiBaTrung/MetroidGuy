class_name DecisionEngineBomb
extends DecisionEngine

# Decision engine for the Bomb Monster.
# Same flow as DecisionEngineBasicAttack (LivingArmor):
#   hit -> stun / death
#   patrol limit -> idle
#   target found by PlayerSensor (collision shape or audio value):
#       close enough (blackboard.distance_to_target <= attack_range) -> explode
#       otherwise -> chase
#   no target -> walk
#
# States are found by unique name (%Name), like the other engines.

@onready var es_walk: ESWalk = %ESWalk
@onready var es_chase: ESChase = %ESChase
@onready var es_attack: ESAttackExplode = %ESAttack
@onready var es_stun: ESStun = %ESStun
@onready var es_death: ESDeath = %ESDeath
@onready var es_idle: ESIdle = %ESIdle


func _ready() -> void:
	await super() # keeps the important setup code / timing
	pass


func decide() -> EnemyState:
	# got hit
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return es_death
		else:
			return es_stun

	if current_state is ESDeath or not blackboard.can_decide:
		return null

	if blackboard.hit_patrol_limit:
		return es_idle

	# PlayerSensor (collision shape or audio) has found the player
	if blackboard.target:
		if es_attack.can_attack():
			return es_attack
		return es_chase

	# turn around at ledges while patrolling
	if blackboard.edge_detected:
		enemy.change_dir( -blackboard.dir )

	return es_walk
