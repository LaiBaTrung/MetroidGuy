@tool
@icon("res://general/icons/enemy.svg")
extends CharacterBody2D
class_name Enemy

signal direction_changed( new_dir )
signal was_hit( a : AttackArea )
signal was_killed()

@export var health : float = 3
@export var affected_by_gravity : bool = true
@export var face_left_from_start : bool = false :
	set( value ):
		face_left_from_start = value
		_update_face_left()


var sprite : Sprite2D
var animation : AnimationPlayer
var damage_area : DamageArea
var hazard_area : HazardArea

var state_machine : EnemyStateMachine
var decision_engine : DecisionEngine
var blackboard : BLackBoard

func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process( false )
		return
	setup()
	pass
	
	
func setup() -> void:
	blackboard = BLackBoard.new()
	blackboard.health = health
	
	for c in get_children():
		if c is AnimationPlayer and not animation:
			animation = c
		elif c is Sprite2D and not sprite:
			sprite = c
		elif c is DamageArea and not damage_area:
			damage_area = c
			c.damage_taken.connect( _on_damage_taken )
		elif c is HazardArea and not hazard_area:
			hazard_area = c 
		elif c is EnemyStateMachine and not state_machine:
			state_machine = c
		elif c is DecisionEngine and not decision_engine:
			decision_engine = c
		pass
	
	if state_machine and decision_engine:
		state_machine.setup( self, blackboard )
		decision_engine.enemy = self
		decision_engine.blackboard = blackboard
	else:
		set_physics_process( false )
	pass

# will move enemy and call state_machine.phy process
func _physics_process(delta: float) -> void:
	blackboard.update_distance_to_target( global_position )
	state_machine.change_state( decision_engine.decide() )
	if affected_by_gravity:
		velocity += get_gravity() * delta
	state_machine.physics_update( delta )
	move_and_slide()
	pass

# change direction - flip the sprite
func change_dir( new_dir : float ) -> void:
	blackboard.dir = new_dir
	direction_changed.emit( new_dir )
	if sprite:
		if new_dir < 0:
			sprite.flip_h = true
		elif new_dir > 0:
			sprite.flip_h = false
	pass


func play_animation( anim_name : String ) -> void:
	if animation.has_animation( anim_name ):
		animation.play( anim_name )
	else:
		printerr("anim missing: ", anim_name)
	pass
	
func _on_damage_taken( a : AttackArea ) -> void:
	blackboard.damage_source = a
	blackboard.health -= a.damage
	if blackboard.health <= 0:
		damage_area.queue_free()
		hazard_area.queue_free()
		was_killed.emit()
	was_hit.emit( a )
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if not find_children( "*", "AnimationPlayer", false ):
		warnings.append( "require an animation player" )
		
	if not find_children( "*", "Sprite2D", false ):
		warnings.append( "require a Sprite2D node" )
		
	if not find_children( "*", "DamageArea", false ):
		warnings.append( "require a DamageArea node" )
		
	if not find_children( "*", "HazardArea", false ):
		warnings.append( "require a HazardArea node" )
		
	if not find_children( "*", "EnemyStateMachine", false ):
		warnings.append( "require an EnemyStateMachine node" )
		
	if not find_children( "*", "DecisionEngine", false ):
		warnings.append( "require a DecisionEngine node" )
		
	return warnings
	
	
func _update_face_left() -> void:
	if not Engine.is_editor_hint():
		return
	for c in get_children():
		if c is Sprite2D:
			c.flip_h = face_left_from_start
	pass
