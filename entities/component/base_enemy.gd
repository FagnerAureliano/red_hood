extends CharacterBody2D
class_name BaseEnemy

enum _types {
	STATIC = 0,
	CHASER = 1,
	WONDERER = 2,
}

var _direction: Vector2 = Vector2.ZERO
var _player_in_range: BaseCharacter = null
var _on_floor: bool = false
var _is_alive: bool = true
var __on_knockback: bool = false
var _lock_facing: bool = false

@export_category("Objects")
@export var _enemy_texture: EnemyTexture
@export var _knockback_timer: Timer

@export_category("Variables")
@export var _enemy_type: _types
@export var _move_speed: float = 128.0
@export var _knockback_force: float = 140.0
@export var _knockback_deceleration: float = 1400.0
@export var _floor_detection_ray: RayCast2D
@export var _enemy_health: int = 10

func get_facing_dir_x() -> float:
	# Preferência: direção lógica do inimigo; fallback: velocidade atual.
	if absf(_direction.x) > 0.001:
		return signf(_direction.x)
	if absf(velocity.x) > 0.001:
		return signf(velocity.x)
	return 1.0

func is_facing_right() -> bool:
	return get_facing_dir_x() > 0.0

func is_facing_locked() -> bool:
	return _lock_facing

func _ready() -> void:
	_direction = [Vector2(1, 0), Vector2(-1, 0)].pick_random()
	if _floor_detection_ray != null:
		_floor_detection_ray.enabled = true
		_floor_detection_ray.exclude_parent = true
		_floor_detection_ray.position.x = abs(_floor_detection_ray.position.x) * signf(_direction.x)

func _physics_process(_delta: float) -> void:
	_vertical_movement(_delta)
	if not _is_alive:
		move_and_slide()
		return

	if __on_knockback:
		# Freia o X durante o knockback pra não arremessar longe demais.
		velocity.x = move_toward(velocity.x, 0.0, _knockback_deceleration * _delta)
		move_and_slide()
		_enemy_texture.animate(velocity)
		return

	var attack_target := _get_attack_target()
	if attack_target != null:
		_attack()
		return

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
		if not _is_alive:
			velocity = Vector2.ZERO
			return
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
		_floor_detection_ray.position.x = - _floor_detection_ray.position.x

	velocity.x = _direction.x * _move_speed

func _attack() -> void:
	pass

func _get_attack_target() -> BaseCharacter:
	if not is_instance_valid(_player_in_range):
		return null
	if _player_in_range.has_method("is_dead") and _player_in_range.is_dead():
		_player_in_range = null
		return null
	return _player_in_range

func update_health(_damage: int, _entity) -> void:
	if not _is_alive:
		return
	global.spawn_damage_popup(_damage, global_position)
	_enemy_health -= _damage
	if _enemy_health <= 0:
		_kill()
		return

	# Enquanto o player estiver perto, não deixe o knockback virar o inimigo.
	_lock_facing = true

	# Animação de hit deve tocar junto com o knockback (sem travar física).
	_enemy_texture.action_animate("hit", false)
	_knockback(_entity)
	
func _knockback(_entity) -> void:
	var _knockback_direction: Vector2 = _entity.global_position.direction_to(global_position)
	velocity = Vector2(
		_knockback_direction.x * _knockback_force,
		-_knockback_force * 0.6
	)
	if _knockback_timer != null:
		_knockback_timer.start()
	__on_knockback = true

func _kill() -> void:
	_enemy_texture.action_animate("dead_hit")
	__on_knockback = false
	if _knockback_timer != null:
		_knockback_timer.stop()
	velocity = Vector2.ZERO
	_is_alive = false
	_drop_items()

func _drop_items() -> void:
	pass

func _on_detection_area_body_entered(_body: Node2D) -> void:
	if _body is BaseCharacter:
		if _body.has_method("is_dead") and _body.is_dead():
			return
			
		print("Enemy detected a character!")
		_player_in_range = _body



func _on_detection_area_body_exited(_body: Node2D) -> void:
	if _body is BaseCharacter:
		print("Enemy lost sight of a character!")
		_player_in_range = null
		_lock_facing = false


func _on_knockback_timer_timeout() -> void:
	__on_knockback = false
