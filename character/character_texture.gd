extends AnimatedSprite2D

class_name CharacterTexture

var _is_on_action: bool = false
var _current_action: String = ""

@export_category("Objects")
@export var _character: BaseCharacter

func _ready() -> void:
	if _character == null:
		var parent := get_parent()
		if parent is BaseCharacter:
			_character = parent

	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)

func animate(_velocity: Vector2) -> void:
	_verify_direction(_velocity)

	if _is_on_action:
		return
	  
	var on_floor := true
	var parent := get_parent()
	if parent != null and parent.has_method("is_on_floor"):
		on_floor = parent.is_on_floor()

	if not on_floor:
		play("jump")
		return
	if _velocity.x != 0: 
		play("run")
		return
	
	play("idle")

func is_in_action() -> bool:
	return _is_on_action
	
func _verify_direction(_velocity: Vector2) -> void:
	if _velocity.x > 0:
		flip_h = false
	elif _velocity.x < 0:
		flip_h = true

func action_animation(_action_name: String) -> void:
	_is_on_action = true
	_current_action = _action_name

	if _action_name == "archer_attack":
		play(_action_name)
		return 
	play(_action_name)

func _on_animation_finished() -> void:
	_character.set_physics_process(true)
	_is_on_action = false
	if _character != null and _character.has_method("_on_action_finished"):
		_character.call("_on_action_finished", _current_action)
	_current_action = ""


func _on_frame_changed() -> void:
	if animation == "run":
		if frame == 2 or frame == 8 or frame == 14 or frame == 20:
			global.spawn_effect("res://visual_effects/dust_particles/run/run_effect.tscn",
			Vector2(0, 11), global_position, flip_h)
