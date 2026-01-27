extends CanvasLayer

class_name TransitionScreen

signal on_transition_finished

@onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false
	_animation.animation_finished.connect(_on_animation_finished)

func fade_in() -> void:
	visible = true
	_animation.play("fade_in")

func fade_out() -> void:
	# visible = true is not strictly needed if we assume we are already black
	_animation.play("fade_out")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		on_transition_finished.emit()
		# Optionally wait or just let the caller handle the next step
	elif anim_name == "fade_out":
		visible = false
