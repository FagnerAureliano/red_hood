extends CharacterBody2D

class_name BaseCharacter
 
var _jump_count: int = 0
var _on_floor: bool = true
var _has_bow: bool = false
var _has_knife: bool = false
var _has_axe: bool = false
var _on_knockback: bool = false

var _knife_combo_step: int = 0
var _axe_combo_step: int = 0

var _pending_axe_vfx: bool = false
var _pending_axe_vfx_step: int = 0
var _pending_axe_vfx_offset: Vector2 = Vector2.ZERO
var _pending_axe_vfx_flip_h: bool = false

var _camera: Camera2D = null
var _camera_base_offset: Vector2 = Vector2.ZERO
var _camera_base_offset_abs_x: float = 0.0
var _camera_face_offset_x: float = 0.0
var _shake_time_left: float = 0.0
var _shake_strength: float = 0.0
var _rng := RandomNumberGenerator.new()
var _combo_wait_time_base: float = 0.0

const throwable_bow_scene: PackedScene = preload("res://throwables/character_bow/character_bow.tscn")

@export_category("Camera")
@export var _camera_face_lerp_speed: float = 3.0
@export var _camera_offset_x: float = 100.0
@export var _camera_smoothing_base: float = 8.0
@export var _camera_smoothing_up: float = 4.0

@export_category("Variables")
@export var _speed: float = 150.0
@export var _jump_velocity: float = -280.0
@export var _character_health: int = 40
@export var _knockback_speed: float = 10.0

@export_category("Objects")
@export var _character_texture: CharacterTexture
@export var _attack_combo_timer: Timer


func _ready() -> void:
	if _attack_combo_timer != null:
		_combo_wait_time_base = _attack_combo_timer.wait_time

	_rng.randomize()
	_camera = get_node_or_null("Camera2D") as Camera2D
	if _camera != null:
		_camera_base_offset = _camera.offset
		_camera_base_offset_abs_x = absf(_camera_base_offset.x)
		_camera_face_offset_x = _camera_base_offset.x

	# Prevent initial camera drift when smoothing is enabled.
	call_deferred("_snap_camera_on_start")


func _process(delta: float) -> void:
	_update_camera_facing(delta)
	_update_camera_smoothing(delta)

	if _shake_time_left <= 0.0:
		return

	if _camera == null:
		_camera = get_node_or_null("Camera2D") as Camera2D
		if _camera != null:
			_camera_base_offset = _camera.offset
			_camera_base_offset_abs_x = absf(_camera_base_offset.x)
		else:
			_shake_time_left = 0.0
			_shake_strength = 0.0
			return

	_shake_time_left -= delta
	_camera.offset = Vector2(_camera_face_offset_x, _camera_base_offset.y) + Vector2(
		_rng.randf_range(-_shake_strength, _shake_strength),
		_rng.randf_range(-_shake_strength, _shake_strength)
	)

	if _shake_time_left <= 0.0:
		_camera.offset = Vector2(_camera_face_offset_x, _camera_base_offset.y)
		_shake_strength = 0.0


func camera_shake(strength: float = 3.5, duration: float = 0.07) -> void:
	_shake_strength = maxf(_shake_strength, strength)
	_shake_time_left = maxf(_shake_time_left, duration)


func _update_camera_smoothing(delta: float) -> void:
	if _camera == null:
		return
	if not _camera.position_smoothing_enabled:
		return

	var target_speed: float = _camera_smoothing_base
	if velocity.y < -50.0:
		target_speed = _camera_smoothing_up

	_camera.position_smoothing_speed = lerpf(_camera.position_smoothing_speed, target_speed, delta * 5.0)


func _update_camera_facing(delta: float) -> void:
	if _camera == null:
		return

	# Use visual facing (flip_h) when available; fallback to velocity.
	var facing_right := true
	if _character_texture != null:
		facing_right = not _character_texture.flip_h
	elif absf(velocity.x) > 0.001:
		facing_right = velocity.x > 0.0

	var target_x := _camera_offset_x if facing_right else -_camera_offset_x
	_camera_face_offset_x = lerpf(_camera_face_offset_x, target_x, clampf(_camera_face_lerp_speed * delta, 0.0, 1.0))
	if _shake_time_left <= 0.0:
		_camera.offset = Vector2(_camera_face_offset_x, _camera_base_offset.y)


func _snap_camera_on_start() -> void:
	var cam := get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		return

	cam.make_current()
	cam.reset_smoothing()

	# Some projects also use smoothed limits; a second reset after the first frame
	# ensures we start exactly at the target.
	await get_tree().process_frame
	if is_instance_valid(cam):
		cam.reset_smoothing()


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

	if _has_knife and event.is_action_pressed("knife_attack"):
		knife_attack()
		return

	if _has_axe and event.is_action_pressed("axe_attack"):
		axe_attack()
		return


func _vertical_movement(_delta: float) -> void:
	if is_on_floor():
		if not _on_floor:
			global.spawn_effect("res://visual_effects/dust_particles/fall/fall_effect.tscn",
			Vector2(0, 11), global_position, false)
			_character_texture.action_animation("land")
			set_physics_process(false)
			_on_floor = true

		_jump_count = 0
		pass

	if not is_on_floor():
		_on_floor = false
		velocity += get_gravity() * _delta

	if Input.is_action_just_pressed("jump") and (_jump_count < 2):
		velocity.y = _jump_velocity
		_jump_count += 1
		global.spawn_effect("res://visual_effects/dust_particles/jump/jump_effect.tscn",
		Vector2(0, 11), global_position, _character_texture.flip_h)
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5


func _horizontal_movement() -> void:
	if _on_knockback:
		velocity.x = lerpf(velocity.x, 0.0, 0.1)
		return

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


func update_knife_state(_state: bool) -> void:
	_has_knife = _state
	if _state:
		_knife_combo_step = 0

func update_axe_state(_state: bool) -> void:
	_has_axe = _state
	if _state:
		_axe_combo_step = 0

func knife_attack() -> void:
	_start_attack_combo_timer()

	_knife_combo_step = (_knife_combo_step % 3) + 1
	var anim_name := "attack_%d_with_knife" % _knife_combo_step
	var offset := Vector2(40, 1)
	if _character_texture.flip_h:
		offset.x = -offset.x

	global.spawn_effect(
		"res://visual_effects/knife/attack_%d/attack_%d.tscn" % [_knife_combo_step, _knife_combo_step],
		offset,
		global_position,
		_character_texture.flip_h
	)

	if not is_on_floor():
		_character_texture.action_animation(anim_name)
		return
	set_physics_process(false)
	_character_texture.action_animation(anim_name)

func axe_attack() -> void:
	_start_attack_combo_timer(0.2)
	_axe_combo_step = (_axe_combo_step % 3) + 1
	var anim_name := "attack_%d_with_axe" % _axe_combo_step
	var offset := Vector2(30, 1)
	if _character_texture.flip_h:
		offset.x = -offset.x

	# VFX is triggered by CharacterTexture on frame 4 (see `_on_frame_changed`).
	_pending_axe_vfx = true
	_pending_axe_vfx_step = _axe_combo_step
	_pending_axe_vfx_offset = offset
	_pending_axe_vfx_flip_h = _character_texture.flip_h

	if not is_on_floor():
		_character_texture.action_animation(anim_name)
		return
	set_physics_process(false)
	_character_texture.action_animation(anim_name)


func spawn_pending_axe_effect() -> void:
	if not _pending_axe_vfx:
		return
	_pending_axe_vfx = false

	global.spawn_effect(
		"res://visual_effects/knife/attack_%d/attack_%d.tscn" % [_pending_axe_vfx_step, _pending_axe_vfx_step],
		_pending_axe_vfx_offset,
		global_position,
		_pending_axe_vfx_flip_h
	)

func spawn_bow_projectile(_facing_left: bool) -> void:
	var bow_instance := throwable_bow_scene.instantiate() as CharacterBow
	if bow_instance == null:
		return

	var parent := get_parent()
	if parent == null:
		return
	bow_instance.direction = Vector2(-1, 0) if _facing_left else Vector2(1, 0)
	parent.call_deferred("add_child", bow_instance)
	bow_instance.call_deferred("set_global_position", global_position + Vector2(0, 0))

func update_health(_value: int, _entity) -> void:
	_knockback(_entity)
	_character_health -= _value
	if _character_health <= 0:
		_character_health = 0
		_character_texture.action_animation("dead_hit")
		set_physics_process(false)

		return
	_character_texture.action_animation("hit")

func _knockback(_entity) -> void:
	var _knockback_direction: Vector2 = _entity.global_position.direction_to(global_position)
	velocity = Vector2(
		_knockback_direction.x * _knockback_speed,
		-_knockback_speed * 0.6
	)
	_on_knockback = true

func collect_item(_items: Array) -> void:
	print("Collecting items: %s" % _items)
	for item_id in _items:
		# Implement item collection logic here.
		pass

func _on_attack_combo_timeout() -> void:
	_knife_combo_step = 0
	_axe_combo_step = 0

func _on_action_finished(_action_name: String) -> void:
	if _action_name == "hit":
		_on_knockback = false

func is_dead() -> bool:
	return _character_health <= 0

