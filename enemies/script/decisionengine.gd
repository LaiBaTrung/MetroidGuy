extends Node
class_name DecisionEngine

var enemy : Enemy
var current_state : EnemyState
var blackboard : BLackBoard

func _ready() -> void:
	while not enemy:
		await  get_tree().process_frame
	enemy.change_dir( -1.0 if enemy.face_left_from_start else 1.0 )
	pass
	

func decide() -> EnemyState:
	# decisions and conditions here
	return null
