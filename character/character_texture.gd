extends AnimatedSprite2D

class_name CharacterTexture

var _is_on_action: bool = false
var _current_action: String = ""

@export_category("Objects")
@export var _character: BaseCharacter
@export var _attack_area_colision: CollisionShape2D

func _ready() -> void:
	if _character == null:
		var parent := get_parent()
		if parent is BaseCharacter:
			_character = parent

	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)

	if not animation_changed.is_connected(_on_animation_changed):
		animation_changed.connect(_on_animation_changed)

	_disable_attack_area()


func _disable_attack_area() -> void:
	if _attack_area_colision != null:
		_attack_area_colision.set_deferred("disabled", true)


func _enable_attack_area() -> void:
	if _attack_area_colision != null:
		_attack_area_colision.set_deferred("disabled", false)

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
		_attack_area_colision.position.x = absf(_attack_area_colision.position.x)
	elif _velocity.x < 0:
		flip_h = true
		_attack_area_colision.position.x = -absf(_attack_area_colision.position.x)

func action_animation(_action_name: String) -> void:
	_is_on_action = true
	_current_action = _action_name

	# Safety: if the action gets interrupted before reaching the "disable" frame,
	# we still won't leave the hitbox active.
	_disable_attack_area()

	# Force restart to ensure signals emit correctly
	stop()
	play(_action_name)

func _on_animation_finished() -> void:
	_disable_attack_area()

	if _current_action == "dead_hit":
		if _character != null and _character.has_method("_on_action_finished"):
			_character.call("_on_action_finished", _current_action)
		return
	
	_character.set_physics_process(true)
	_is_on_action = false
	if _character != null and _character.has_method("_on_action_finished"):
		_character.call("_on_action_finished", _current_action)
	_current_action = ""


func _on_animation_changed() -> void:
	# If a knife/axe attack gets interrupted (fall/jump/land/etc), make sure the
	# hitbox isn't left active.
	if not (animation.contains("knife") or animation.contains("axe")):
		_disable_attack_area()


func _on_frame_changed() -> void:
	if animation.contains("knife"):
		if frame == 0 or frame == 1:
			_enable_attack_area()
		else:
			_disable_attack_area()
	
	if animation.contains("axe"):
		var vfx_frame := 6 if animation == "attack_3_with_axe" else 4
		if frame == vfx_frame:
			if _character != null and _character.has_method("spawn_pending_axe_effect"):
				_character.call("spawn_pending_axe_effect")
		if frame == 7 or frame == 8:
			_enable_attack_area()
		else:
			_disable_attack_area()
	
	if animation == "archer_attack":
		if frame == 8:
			_character.spawn_bow_projectile(flip_h)
	if animation == "run":
		if frame == 2 or frame == 8 or frame == 14 or frame == 20:
			global.spawn_effect("res://visual_effects/dust_particles/run/run_effect.tscn",
			Vector2(0, 11), global_position, flip_h)
