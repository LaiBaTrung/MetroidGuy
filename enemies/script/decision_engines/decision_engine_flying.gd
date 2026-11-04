class_name DecisionEngineFlying	
extends DecisionEngine

@export var idle_state : EnemyState
@export var move_state : EnemyState
@export var chase_state : EnemyState
@export var attack_state : EnemyState
@export var stun_state : EnemyState
@export var death_state : EnemyState


func _ready() -> void:
	await super() # Maintains important setup code, timing
	# add custom script here
	pass

func decide() -> EnemyState:
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return death_state
		elif not stun_state is ESStun or ( stun_state as ESStun ).can_stun():
			return stun_state
		# stun immunity: the hit still hurt (health is already down), carry on deciding
		blackboard.damage_source = null
			
	if current_state is ESDeath or not blackboard.can_decide:
		return null
	
	if blackboard.target: 
		if attack_state.can_attack():
			return attack_state
		return chase_state
	return move_state
