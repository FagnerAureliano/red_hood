extends CharacterBody2D

class_name BaseCharacter
 
var _jump_count: int = 0
var _on_floor: bool = true
var _has_bow: bool = false
var _has_sword: bool = false
var _has_axe: bool = false

var _sword_combo_step: int = 0
var _axe_combo_step: int = 0

@export_category("Variables")
@export var _speed: float = 200.0
@export var _jump_velocity: float = -300.0
@export_category("Objects")
@export var _character_texture: CharacterTexture
@export var _attack_combo_timer: Timer

var _combo_wait_time_base: float = 0.0

func _ready() -> void:
	if _attack_combo_timer != null:
		_combo_wait_time_base = _attack_combo_timer.wait_time



func _start_attack_combo_timer(extra_time_sec: float = 0.0) -> void:
	if _attack_combo_timer == null:
		return
	if _combo_wait_time_base > 0.0:
		_attack_combo_timer.wait_time = _combo_wait_time_base + extra_time_sec
	_attack_combo_timer.start()


func _physics_process(_delta: float) -> void:
	_vertical_movement(_delta)
	_horizontal_movement()
	move_and_slide()
	_character_texture.animate(velocity)


func _unhandled_input(event: InputEvent) -> void:
	# Don't buffer clicks: only accept a new attack when the previous action finished.
	if _character_texture != null and _character_texture.is_in_action():
		return

	if _has_bow and event.is_action_pressed("archer_attack"):
		_bow_attack()
		return

	if _has_sword and event.is_action_pressed("sword_attack"):
		sword_attack()
		return

	if _has_axe and event.is_action_pressed("axe_attack"):
		axe_attack()
		return


func _vertical_movement(_delta: float) -> void:
	if is_on_floor():
		if not _on_floor:
			_character_texture.action_animation("land")
			set_physics_process(false)
			_on_floor = true

		_jump_count = 0
		pass

	if not is_on_floor():
		_on_floor = false
		velocity += get_gravity() * _delta

	# Handle jump and douyble jump
	if Input.is_action_just_pressed("jump") and (_jump_count < 2):
		velocity.y = _jump_velocity
		_jump_count += 1 


func _horizontal_movement() -> void:
	var _direction := Input.get_axis("move_left", "move_right")
	if _direction:
		velocity.x = _direction * _speed
		return

	velocity.x = move_toward(velocity.x, 0, _speed)

func _bow_attack() -> void:
	if not is_on_floor():
		_character_texture.action_animation("archer_attack")
		return
	set_physics_process(false)
	_character_texture.action_animation("archer_attack")

func update_archer_state(_state: bool) -> void: 
	self._has_bow = _state


func update_sword_state(_state: bool) -> void:
	_has_sword = _state
	if _state:
		_sword_combo_step = 0

func update_axe_state(_state: bool) -> void:
	_has_axe = _state
	if _state:
		_axe_combo_step = 0

func sword_attack() -> void:
	_start_attack_combo_timer()
	_sword_combo_step = (_sword_combo_step % 3) + 1
	var anim_name := "attack_%d_with_sword" % _sword_combo_step

	if not is_on_floor():
		_character_texture.action_animation(anim_name)
		return
	set_physics_process(false)
	_character_texture.action_animation(anim_name)

func axe_attack() -> void:
	_start_attack_combo_timer(0.2)
	_axe_combo_step = (_axe_combo_step % 3) + 1
	var anim_name := "attack_%d_with_axe" % _axe_combo_step

	if not is_on_floor():
		_character_texture.action_animation(anim_name)
		return
	set_physics_process(false)
	_character_texture.action_animation(anim_name)

func _on_attack_combo_timeout() -> void:
	_sword_combo_step = 0
	_axe_combo_step = 0
