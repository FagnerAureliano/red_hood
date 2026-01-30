extends CharacterBody2D

class_name BaseCharacter
 
var _on_knockback: bool = false

var _fsm: CharacterStateMachine

var _camera_rig: CameraRig
var _input_component: CharacterInputComponent
var _movement_component: CharacterMovementComponent
var _combat_component: CharacterCombatComponent

const throwable_bow_scene: PackedScene = preload("res://throwables/character_bow/character_bow.tscn")

@export_category("Variables")
@export var _character_health: int = 40
@export var _knockback_speed: float = 10.0

@export_category("Objects")
@export var _inventory: CharacterInventory
@export var _character_texture: CharacterTexture


func _ready() -> void:
	_camera_rig = get_node_or_null("Camera2D") as CameraRig

	_setup_fsm()
	_setup_components()
	_setup_lighting()


func _setup_lighting() -> void:
	if not has_node("CharacterLightComponent"):
		var light = CharacterLightComponent.new()
		light.name = "CharacterLightComponent"
		add_child(light)




func camera_shake(strength: float = 3.5, duration: float = 0.07) -> void:
	if _camera_rig != null:
		_camera_rig.camera_shake(strength, duration)


func _physics_process(_delta: float) -> void:
	if _fsm == null:
		return
	_fsm.physics_process(_delta)


func _unhandled_input(event: InputEvent) -> void:
	if _fsm == null:
		return
	_fsm.handle_input(event)

func _bow_attack() -> void:
	if _combat_component != null:
		_combat_component.bow_attack()

func update_archer_state(_state: bool) -> void:
	if _combat_component != null:
		_combat_component.update_archer_state(_state)


func update_knife_state(_state: bool) -> void:
	if _combat_component != null:
		_combat_component.update_knife_state(_state)

func update_axe_state(_state: bool) -> void:
	if _combat_component != null:
		_combat_component.update_axe_state(_state)

func knife_attack() -> void:
	if _combat_component != null:
		_combat_component.knife_attack()

func axe_attack() -> void:
	if _combat_component != null:
		_combat_component.axe_attack()


func spawn_pending_axe_effect() -> void:
	if _combat_component != null:
		_combat_component.spawn_pending_axe_effect()

func spawn_bow_projectile(_facing_left: bool) -> void:
	if _combat_component != null:
		_combat_component.spawn_bow_projectile(_facing_left)

func update_health(_value: int, _entity) -> void:
	if is_in_state("dead"):
		return

	_knockback(_entity)
	_character_health -= _value
	if _character_health <= 0:
		_character_health = 0
		_set_state("dead")
		_character_texture.action_animation("dead_hit")
		set_physics_process(false)

		return
	_set_state("hit")
	_character_texture.action_animation("hit")

func _knockback(_entity) -> void:
	var _knockback_direction: Vector2 = _entity.global_position.direction_to(global_position)
	velocity = Vector2(
		_knockback_direction.x * _knockback_speed,
		- _knockback_speed * 0.6
	)
	_on_knockback = true

func collect_item(_items: Array) -> void:
	print("Collecting items: %s" % _items)
	_inventory.add_items(_items)

func _on_attack_combo_timeout() -> void:
	if _combat_component != null:
		_combat_component.reset_combo()

func _on_action_finished(_action_name: String) -> void:
	if _action_name == "hit":
		_on_knockback = false
		_set_state("normal")

	if _action_name == "land":
		_set_state("normal")

	if _action_name == "archer_attack" or _action_name.begins_with("attack_"):
		_set_state("normal")

	if _action_name == "dead_hit":
		global.game_over_reload()

func is_dead() -> bool:
	return _character_health <= 0

func _setup_fsm() -> void:
	_fsm = CharacterStateMachine.new()
	add_child(_fsm)
	_fsm.setup(self, {
		"normal": preload("res://scripts/FSM/character_normal_state.gd"),
		"attack": preload("res://scripts/FSM/character_attack_state.gd"),
		"hit": preload("res://scripts/FSM/character_hit_state.gd"),
		"dash": preload("res://scripts/FSM/character_dash_state.gd"),
		"dead": preload("res://scripts/FSM/character_dead_state.gd")
	})
	_fsm.change_state("normal")

func _set_state(_name: String) -> void:
	if _fsm != null:
		_fsm.change_state(_name)

func is_in_state(_name: String) -> bool:
	return _fsm != null and _fsm.is_in_state(_name)

func _setup_components() -> void:
	if _input_component == null:
		_input_component = get_node_or_null("CharacterInput") as CharacterInputComponent
	if _movement_component == null:
		_movement_component = get_node_or_null("CharacterMovement") as CharacterMovementComponent
	if _combat_component == null:
		_combat_component = get_node_or_null("CharacterCombat") as CharacterCombatComponent

	if _input_component != null:
		_input_component.setup(self)
	if _movement_component != null:
		_movement_component.setup(self)
	if _combat_component != null:
		_combat_component.setup(self)
