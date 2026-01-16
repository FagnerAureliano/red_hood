extends AnimatedSprite2D
class_name EnemyTexture

var _on_action: bool = false
@export_category("Objects")
@export var _enemy:BaseEnemy

func animate(_velocity: Vector2) -> void:
	if _on_action:
		return

	# Ajusta orientação: por padrão, sprite "olha" para a direita.
	if _velocity.x != 0.0:
		flip_h = _velocity.x < 0.0

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
	

func action_animate(_action: String) -> void:
	_enemy.set_physics_process(false)
	_on_action = true
	play(_action)

func _on_animation_finished() -> void:
	_on_action = false
	_enemy.set_physics_process(true)
