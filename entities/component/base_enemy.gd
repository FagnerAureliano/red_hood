extends CharacterBody2D
class_name BaseEnemy

enum _types {
	STATIC = 0,
	CHASER = 1,
	WONDERER = 2,
}

var _direction: Vector2 = Vector2.ZERO
var _on_floor: bool = false

@export_category("Objects")
@export var _enemy_texture: EnemyTexture

@export_category("Variables")
@export var _enemy_type:_types
@export var _move_speed: float = 128.0
@export var _floor_detection_ray: RayCast2D

func _ready() -> void:
	_direction = [Vector2(1, 0), Vector2(-1, 0)].pick_random()
	if _floor_detection_ray != null:
		_floor_detection_ray.enabled = true
		_floor_detection_ray.exclude_parent = true
		_floor_detection_ray.position.x = abs(_floor_detection_ray.position.x) * signf(_direction.x)

func _physics_process(_delta: float) -> void:
	_vertical_movement(_delta)
	match _enemy_type:
		_types.STATIC:
			_static(_delta)
			pass
		_types.CHASER:
			_chaser(_delta)
		_types.WONDERER:
			_wonderer(_delta)
	move_and_slide()

	_enemy_texture.animate(velocity)

func _vertical_movement(_delta: float) -> void:
	if is_on_floor():
		if _on_floor == false:
			_enemy_texture.action_animate("land")
			_on_floor = true

	if not is_on_floor():
		velocity += get_gravity() * _delta

func _static(_delta: float) -> void:
	# Placeholder for static movement logic
	pass

func _chaser(_delta: float) -> void:
	# Placeholder for chaser movement logic
	pass
func _wonderer(_delta: float) -> void:
	if _floor_detection_ray == null:
		return


	var should_turn := false
	if is_on_floor() and not _floor_detection_ray.is_colliding():
		should_turn = true
	elif is_on_floor():
		# Detecta parede à frente de forma confiável (antes do move_and_slide).
		var step := maxf(2.0, _move_speed * _delta)
		var motion := Vector2(signf(_direction.x) * step, 0.0)
		if test_move(global_transform, motion):
			should_turn = true

	if should_turn:
		_direction.x *= -1.0
		_floor_detection_ray.position.x = -_floor_detection_ray.position.x

	velocity.x = _direction.x * _move_speed