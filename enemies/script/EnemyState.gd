@icon("res://player/states/state.svg")
extends Node
class_name EnemyState

@export var animation_name : String

var state_machine : EnemyStateMachine
var enemy : Enemy
var blackboard : BLackBoard

# what happens when we enter this state ?
func enter() -> void:
	pass
	
# what happens when we called this state again ?
func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update( _delta : float ) -> void:
	pass
