extends Node
class_name AbilitiesList

@onready var ability_double_jump: Button = %AbilityDoubleJump
@onready var ability_dash: Button = %AbilityDash
@onready var ability_ground_slam: Button = %AbilityGroundSlam
@onready var ability_morph_roll: Button = %AbilityMorphRoll
@onready var abilities_description: Label = %AbilitiesDescription

const DESCRIPTIONS := {
	"double_jump": "Double Jump: Press jump again in mid-air to jump a second time.",
	"dash": "Dash: Quickly burst forward in the direction you're facing.",
	"ground_slam": "Ground Slam: Slam down from the air to hit the ground with force.",
	"morph_roll": "Morph Roll: Shrink into a ball to roll through tight spaces.",
}

func _ready() -> void:
	var player : Player = get_tree().get_first_node_in_group( "Player" )
	ability_dash.visible = player.dash
	ability_double_jump.visible = player.double_jump
	ability_ground_slam.visible = player.ground_slam
	ability_morph_roll.visible = player.morph_roll
	
	_connect_hover( ability_double_jump, "double_jump" )
	_connect_hover( ability_dash, "dash" )
	_connect_hover( ability_ground_slam, "ground_slam" )
	_connect_hover( ability_morph_roll, "morph_roll" )
	pass

func _connect_hover( button : Button, key : String ) -> void:
	button.mouse_entered.connect( display_abilites_description.bind(key) )
	button.mouse_exited.connect( clear_abilities_description )
	pass
func display_abilites_description( ability_key : String ) -> void:
	abilities_description.text = DESCRIPTIONS.get( ability_key, "" )
	pass
	
func clear_abilities_description() -> void:
	abilities_description.text = ""
	pass
