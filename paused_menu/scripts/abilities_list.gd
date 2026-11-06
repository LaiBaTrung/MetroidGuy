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
const NAMES := {
	"double_jump": "Double jump",
	"dash": "Dash",
	"ground_slam": "Ground slam",
	"morph_roll": "Morph roll",
}
const LOCKED_TEXT := "Not yet recovered."
# rows in the order the abilities are found
const ORDER : Array[String] = [ "dash", "morph_roll", "double_jump", "ground_slam" ]
const PLATE : Texture2D = preload( "res://paused_menu/sprites/ability_plate.png" )
const PLATE_LOCKED : Texture2D = preload( "res://paused_menu/sprites/ability_plate_locked.png" )
const ICONS : Texture2D = preload( "res://paused_menu/sprites/ui_icons.png" )
const LOCK_REGION : Rect2 = Rect2( 72, 12, 12, 12 )   # ui_icons.png row 1, column 6
const PLATE_SIZE : Vector2 = Vector2( 21, 21 )

var buttons : Dictionary = {}
var unlocked : Dictionary = {}


func _ready() -> void:
	var player : Player = get_tree().get_first_node_in_group( "Player" )
	buttons = {
		"dash": ability_dash,
		"morph_roll": ability_morph_roll,
		"double_jump": ability_double_jump,
		"ground_slam": ability_ground_slam,
	}
	unlocked = {
		"dash": player.dash,
		"morph_roll": player.morph_roll,
		"double_jump": player.double_jump,
		"ground_slam": player.ground_slam,
	}
	for i in ORDER.size():
		var key : String = ORDER[ i ]
		move_child( buttons[ key ], i )
		_set_up_row( buttons[ key ], key )
	pass


# every row is shown; abilities the player has not found yet are greyed with a lock
func _set_up_row( button : Button, key : String ) -> void:
	var has : bool = unlocked[ key ]
	var icon_texture : Texture2D = button.icon
	button.icon = null
	button.text = NAMES[ key ]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.theme_type_variation = &"AbilityRow" if has else &"AbilityRowLocked"

	var plate : TextureRect = TextureRect.new()
	plate.texture = PLATE if has else PLATE_LOCKED
	plate.position = Vector2( 2, 1 )
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child( plate )

	var icon : TextureRect = TextureRect.new()
	if not has:
		var lock : AtlasTexture = AtlasTexture.new()
		lock.atlas = ICONS
		lock.region = LOCK_REGION
		icon_texture = lock
	icon.texture = icon_texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.size = PLATE_SIZE - Vector2( 2, 2 )
	icon.position = plate.position + Vector2( 1, 1 )
	# keep 1:1 pixels when the icon fits the plate, shrink only the tall ground-slam icon
	var fits : bool = icon_texture and icon_texture.get_size().x <= icon.size.x and icon_texture.get_size().y <= icon.size.y
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED if fits else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child( icon )

	button.focus_entered.connect( display_abilites_description.bind( key ) )
	button.mouse_entered.connect( button.grab_focus )
	pass


func focus_first() -> void:
	buttons[ ORDER[ 0 ] ].grab_focus()
	pass


func display_abilites_description( ability_key : String ) -> void:
	if unlocked.get( ability_key, false ):
		abilities_description.text = DESCRIPTIONS.get( ability_key, "" )
	else:
		abilities_description.text = "%s: %s" % [ NAMES[ ability_key ], LOCKED_TEXT ]
	pass


func clear_abilities_description() -> void:
	abilities_description.text = ""
	pass
