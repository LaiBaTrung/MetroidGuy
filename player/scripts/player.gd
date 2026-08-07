extends CharacterBody2D
class_name Player

const JUMP_DEBUG_INDICATOR = preload("uid://ru5hkhcvor6j")

#region /// signals
signal damage_taken
#endregion

#region /// on ready variables
@onready var sprite: PlayerSprite = $Sprite2D
@onready var attack_sprite: Sprite2D = %AttackSprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var da_stand: CollisionShape2D = %DAStand
@onready var da_crouch: CollisionShape2D = %DACrouch
@onready var one_way_platform_shapecast: ShapeCast2D = $one_way_platform_Shapecast
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_area: AttackArea = %AttackArea
@onready var damage_area: DamageArea = %DamageArea
@onready var ledge_grab: PlayerStateLedgeGrab = %LedgeGrab
@onready var fall: PlayerStateFall = %Fall
#endregion

#region /// export variables
@export var move_speed : float = 150
@export var max_fall_velocity : float = 600.0
#endregion


#region /// State machine variables

var states: Array[ PlayerState ]

var current_state: PlayerState : 
	get : return states.front()
var previous_state: PlayerState :
	get : return states[ 1 ]
	
var facing_direction := 1

var was_on_floor : bool = false
var landing_speed : float = 0.0

var ledge_grab_jump : bool = false
#endregion

#region /// player stats
var hp : float  = 20:
	set( value ):
		hp = clampf(value, 0, max_hp)
		Messages.player_health_changed.emit( hp, max_hp )
		
var max_hp : float = 20:
	set ( value ):
		max_hp = value
		Messages.player_health_changed.emit( hp, max_hp )
var dash : bool = false
var dash_count : int = 0
var double_jump : bool = false
var jump_count : int = 0
var ground_slam : bool = false
var morph_roll  : bool = false
var can_interact : bool = false
#endregion

#region /// standard variables
var direction :  Vector2 = Vector2.ZERO
var gravity : float = 980
var gravity_multiplier : float = 1.0
var direction_locked : bool = false
#endregion


func _ready() -> void:
	if get_tree().get_first_node_in_group( "Player" ) != self:
		self.queue_free()
	initialize_states()
	self.call_deferred("reparent", get_tree().root )
	Messages.player_healed.connect( _on_player_healed )
	Messages.back_to_title_screen.connect( queue_free )
	Messages.input_hint_changed.connect( _on_input_hint_changed )
	damage_area.damage_taken.connect( _on_damage_taken )
	hp = max_hp
	pass
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("Jump") and velocity.y < 0:
		velocity.y *= 0.5
	if event.is_action_pressed( "action" ):
		Messages.player_interacted.emit( self )
	elif event.is_action_pressed("pause"):
		get_tree().paused = true
		var pause_menu : PauseMenu = load( "res://paused_menu/paused_menu.tscn" ).instantiate()  
		add_child( pause_menu )
		return
		
	# get rid later
	if event is InputEventKey and event.pressed: 
		if event.keycode == KEY_MINUS:
			if Input.is_key_pressed(KEY_SHIFT):
				max_hp -= 10 
			else: 
				hp -= 2
		elif event.keycode == KEY_EQUAL:
			if Input.is_key_pressed(KEY_SHIFT):
				max_hp += 10 
			else: 
				hp += 2
		
	# end get rid later
	
	change_state( current_state.handle_inputs(event) )
	pass

func _process( _delta: float ) -> void:
	change_state( current_state.process(_delta) )
	update_direction()
	pass


func _physics_process( _delta: float ) -> void:
	velocity.y += gravity * _delta * gravity_multiplier
	velocity.y = clampf( velocity.y, -1000.0, max_fall_velocity )
	landing_speed = velocity.y
	move_and_slide()
	if !was_on_floor and is_on_floor():
		fall.play_land_sound()
	was_on_floor = is_on_floor()
	change_state( current_state.physics_process(_delta) )
	pass
	

func initialize_states() -> void:
	states = []
	for c in $States.get_children():
		if c is PlayerState:
			states.append( c )
			c.player = self
		pass
		
	if states.size() == 0:
		return
		
	for state in states:
		state.init()
		
	change_state( current_state )
	current_state.enter()
	$Label.text = current_state.name
	pass
	
	
func change_state(new_state : PlayerState) -> void:
	if new_state == null:
		return
		
	elif new_state == current_state:
		return
		
	if current_state:
		current_state.exit()
		
	states.push_front( new_state )
	current_state.enter()
	states.resize( 3 )
	$Label.text = current_state.name
	pass
	

func update_direction() -> void:
	if direction_locked:
		return
	var prev_direction : Vector2 = direction
	var x_axis = Input.get_axis("Left", "Right")
	var y_axis = Input.get_axis("Up", "Down")
	direction = Vector2( x_axis, y_axis )
	
	if prev_direction.x != direction.x and direction.x != 0:
		facing_direction = sign(direction.x)
		attack_area.flip( direction.x )
		ledge_grab.flip(facing_direction)
		if direction.x < 0:
			#left
			sprite.flip_h = true
			attack_sprite.flip_h = true
			attack_sprite.position.x = -24
		
			
		elif direction.x > 0:
			#right
			sprite.flip_h = false
			attack_sprite.flip_h = false
			attack_sprite.position.x = 24
	pass
	

func add_debug_indicator( color : Color = Color.RED ) -> void:
	var d : Node2D = JUMP_DEBUG_INDICATOR.instantiate()
	get_tree().root.add_child( d )
	d.global_position = global_position
	d.modulate = color
	await get_tree().create_timer( 3 ).timeout
	d.queue_free()
	pass
	
	
func _on_player_healed (amount : float)-> void:
	hp += amount
	#audio/visual
	pass
	

func _on_damage_taken( incomming_damage : AttackArea ) -> void:
	if current_state == PlayerStateDeath:
		return
	hp -= incomming_damage.damage
	damage_taken.emit()
	pass

func _on_input_hint_changed( promt_name : String ) -> void:
	if promt_name == "interact":
		can_interact = true
	else:
		can_interact = false
	pass


func can_dash() -> bool:
	if dash == false or dash_count > 0:
		return false
	return true
	
	
func can_morph() -> bool:
	if morph_roll == false or can_interact == true:
		return false
	return true
