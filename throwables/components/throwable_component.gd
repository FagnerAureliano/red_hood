extends Area2D
class_name ThrowableComponent


var direction: Vector2

@export_category("Variables")
@export var speed: float = 700.0
@export var damage: int = 10

func _on_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.


func _physics_process(_delta: float) -> void:
	translate(direction.normalized() * speed * _delta)