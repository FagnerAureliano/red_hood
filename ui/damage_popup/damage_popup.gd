extends Label
class_name DamagePopup

@export var duration: float = 0.55
@export var rise: Vector2 = Vector2(0, -28)
@export var spread_x: float = 8.0
@export var font_size: int = 18
@export var font_color: Color = Color(1.0, 0.95, 0.95)
@export var outline_color: Color = Color(0.0, 0.0, 0.0, 0.9)
@export var outline_size: int = 2

var amount: int = 0

func _ready() -> void:
	z_index = 1000
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text = str(amount)

	# Tunable styling (no extra assets required).
	if font_size > 0:
		add_theme_font_size_override("font_size", font_size)
	add_theme_color_override("font_color", font_color)
	add_theme_color_override("font_outline_color", outline_color)
	add_theme_constant_override("outline_size", outline_size)

	call_deferred("_start")


func _start() -> void:
	# Wait one frame so `size` is correct.
	await get_tree().process_frame

	position -= size * 0.5
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	position.x += rng.randf_range(-spread_x, spread_x)

	var tween := create_tween()
	var move_tweener := tween.tween_property(self, "position", position + rise, duration)
	move_tweener.set_trans(Tween.TRANS_SINE)
	move_tweener.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(Callable(self, "queue_free"))
