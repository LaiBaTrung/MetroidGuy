class_name DecisionEngineBasicAttack	
extends DecisionEngine

@export var attack_state : ESAttack
@export var chase_state : EnemyState

@onready var es_walk: ESWalk = %ESWalk
@onready var es_stun: ESStun = %ESStun
@onready var es_death: ESDeath = %ESDeath
@onready var es_idle: ESIdle = %ESIdle

func _ready() -> void:
	await super()
	pass

func decide() -> EnemyState:
	# example decisions
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return es_death
		else:
			return es_stun
			
	if current_state is ESDeath or not blackboard.can_decide:
		return null
	
	if blackboard.hit_patrol_limit:
		return es_idle
	
	if blackboard.target:
		if attack_state.can_attack():
			return attack_state
		return chase_state
	return es_walk
