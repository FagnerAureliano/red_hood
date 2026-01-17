extends AnimatedSprite2D
class_name EnemyTexture

var _on_action: bool = false
var _enemy_frozen_by_action: bool = false
var _attack_area_x_abs: float = 0.0
@export_category("Objects")
@export var _enemy:BaseEnemy
@export var _attack_area_collision: CollisionShape2D

@export_category("Variables")
@export var _last_attack_frame: int

func _ready() -> void:
	if _attack_area_collision != null:
		_attack_area_x_abs = abs(_attack_area_collision.position.x)
		if _attack_area_x_abs <= 0.0:
			_attack_area_x_abs = 8.0

func _set_facing_right(facing_right: bool) -> void:
	flip_h = not facing_right
	if _attack_area_collision != null:
		_attack_area_collision.position.x = _attack_area_x_abs * (1.0 if facing_right else -1.0)

func animate(_velocity: Vector2) -> void:
	if _on_action:
		return

	# Ajusta orientação: por padrão, sprite "olha" para a direita.
	# Se o inimigo estiver com facing travado, não vire por causa do knockback.
	if is_instance_valid(_enemy) and _enemy.is_facing_locked():
		_set_facing_right(_enemy.is_facing_right())
	elif _velocity.x != 0.0:
		_set_facing_right(_velocity.x > 0.0)

	# Prioriza animações verticais quando houver movimento em Y.
	if _velocity.y < 0.0:
		play("jump")
		return
	elif _velocity.y > 0.0:
		play("fall")
		return

	if _velocity.x != 0.0:
		play("run")
		return

	play("idle")
	

func action_animate(_action: String, _freeze_enemy: bool = true) -> void:
	# Durante a ação (ex: "attack"), a velocidade pode ficar 0.
	# Então usamos a direção do inimigo para orientar o sprite e a hitbox.
	if is_instance_valid(_enemy):
		_set_facing_right(_enemy.is_facing_right())
		if _freeze_enemy:
			_enemy.set_physics_process(false)
			_enemy_frozen_by_action = true
	_on_action = true
	play(_action)

func _on_animation_finished() -> void:
	_on_action = false
	if _enemy_frozen_by_action and is_instance_valid(_enemy):
		_enemy.set_physics_process(true)
	_enemy_frozen_by_action = false


func _on_frame_changed() -> void:
	if animation == "attack":
		if _attack_area_collision == null:
			return
		if frame == 2 or frame == 3:
			_attack_area_collision.disabled = false
		if frame == _last_attack_frame:
			_attack_area_collision.disabled = true