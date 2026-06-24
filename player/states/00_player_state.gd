@icon( "res://player/states/state.svg" )
extends Node
class_name PlayerState

var player: Player
var next_state: PlayerState
 
#region /// states referencs
@onready var idle: PlayerStateIdle = %Idle
@onready var run: PlayerStateRun = %Run
@onready var fall: PlayerStateFall = %Fall
@onready var jump: PlayerStateJump = %Jump
@onready var crouch: PlayerStateCrouch = %Crouch
#endregion


# what when the state is initialized 
func init() -> void:
	pass
	
	
# what happens when enter this state
func enter() -> void:	
	pass
	
	
# what happens when exit this state
func exit() -> void:
	pass 
	
	
# handle what happens when an input is pressed 
func handle_inputs( _event : InputEvent ) -> PlayerState:
	return next_state


# what happens each progress tick in this state
func process(_delta: float) -> PlayerState:
	return next_state


# what happens each progress tick in this state
func physics_process(_delta: float) -> PlayerState:
	return next_state

	
