extends Camera2D

class_name CameraRig

@export_category("Camera")
@export var _face_lerp_speed: float = 3.0
@export var _offset_x: float = 100.0
@export var _smoothing_base: float = 8.0
@export var _smoothing_up: float = 4.0

var _target: BaseCharacter
var _base_offset: Vector2 = Vector2.ZERO
var _face_offset_x: float = 0.0
var _shake_time_left: float = 0.0
var _shake_strength: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	_target = get_parent() as BaseCharacter
	_base_offset = offset
	_face_offset_x = _base_offset.x

	# Prevent initial camera drift when smoothing is enabled.
	call_deferred("_snap_on_start")

func _process(delta: float) -> void:
	_update_facing(delta)
	_update_smoothing(delta)

	if _shake_time_left <= 0.0:
		return

	_shake_time_left -= delta
	offset = Vector2(_face_offset_x, _base_offset.y) + Vector2(
		_rng.randf_range(-_shake_strength, _shake_strength),
		_rng.randf_range(-_shake_strength, _shake_strength)
	)

	if _shake_time_left <= 0.0:
		offset = Vector2(_face_offset_x, _base_offset.y)
		_shake_strength = 0.0

func camera_shake(strength: float = 3.5, duration: float = 0.07) -> void:
	_shake_strength = maxf(_shake_strength, strength)
	_shake_time_left = maxf(_shake_time_left, duration)

func _update_smoothing(delta: float) -> void:
	if not position_smoothing_enabled:
		return
	if _target == null:
		return

	var target_speed: float = _smoothing_base
	if _target.velocity.y < -50.0:
		target_speed = _smoothing_up

	position_smoothing_speed = lerpf(position_smoothing_speed, target_speed, delta * 5.0)

func _update_facing(delta: float) -> void:
	if _target == null:
		return

	# Use visual facing (flip_h) when available; fallback to velocity.
	var facing_right := true
	if _target._character_texture != null:
		facing_right = not _target._character_texture.flip_h
	elif absf(_target.velocity.x) > 0.001:
		facing_right = _target.velocity.x > 0.0

	var target_x := _offset_x if facing_right else -_offset_x
	_face_offset_x = lerpf(_face_offset_x, target_x, clampf(_face_lerp_speed * delta, 0.0, 1.0))
	if _shake_time_left <= 0.0:
		offset = Vector2(_face_offset_x, _base_offset.y)

func _snap_on_start() -> void:
	make_current()
	reset_smoothing()

	# Some projects also use smoothed limits; a second reset after the first frame
	# ensures we start exactly at the target.
	await get_tree().process_frame
	if is_instance_valid(self):
		reset_smoothing()
