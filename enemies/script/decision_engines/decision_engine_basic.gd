class_name DecisionEngineBasic
extends DecisionEngine

# Included in DecisionEngine
# var enemy : Enemy
# var current_state : EnemyState
# var blackboard : BlackBoard

@onready var es_walk: ESWalk = %ESWalk
@onready var es_stun: ESStun = %ESStun
@onready var es_death: ESDeath = %ESDeath


func _ready() -> void:
	await super() # Maintains important setup code, timing
	# add custom script here
	pass

func decide() -> EnemyState:
	# example decisions
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return es_death
		elif es_stun.can_stun():
			return es_stun
		# stun immunity: the hit still hurt (health is already down), carry on deciding
		blackboard.damage_source = null
			
	if current_state is ESDeath or not blackboard.can_decide:
		return null
	
	if blackboard.edge_detected:
		enemy.change_dir( -blackboard.dir )

	# ESWalk stops at a PatrolLimit; turn back like at a ledge instead of standing there for good
	if blackboard.hit_patrol_limit:
		blackboard.hit_patrol_limit = false
		enemy.change_dir( -blackboard.dir )

	return es_walk
