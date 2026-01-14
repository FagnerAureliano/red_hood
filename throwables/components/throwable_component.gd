extends Area2D
class_name ThrowableComponent

var _direction: Vector2 = Vector2.ZERO
var _last_facing_right: bool = true

var direction: Vector2:
	get:
		return _direction
	set(value):
		_direction = value
		_update_flip_h()

@export_category("Variables")
@export var speed: float = 700.0
@export var damage: int = 10

@export_category("Visual")
@export var auto_flip_h: bool = true
@export var texture_faces_right: bool = false


func _ready() -> void:
	_update_flip_h()

func _on_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.


func _update_flip_h() -> void:
	if not auto_flip_h:
		return

	var texture := get_node_or_null("Texture") as AnimatedSprite2D
	if texture == null:
		return

	if absf(_direction.x) > 0.001:
		_last_facing_right = _direction.x > 0.0

	# Flip when the desired facing differs from the texture's default facing.
	texture.flip_h = _last_facing_right != texture_faces_right


func _physics_process(_delta: float) -> void:
	translate(direction.normalized() * speed * _delta)