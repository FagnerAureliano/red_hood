extends Node

class_name CharacterMovementComponent

var actor: BaseCharacter

@export_category("Movement")
@export var _speed: float = 150.0
@export var _jump_velocity: float = -280.0

@export_category("Dash")
@export var _dash_speed: float = 450.0
@export var _dash_duration: float = 0.2
@export var _dash_cooldown: float = 1.0

var _jump_count: int = 0
var _on_floor: bool = true
var _is_dashing: bool = false
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_ghost_timer: float = 0.0

func setup(_actor: BaseCharacter) -> void:
	actor = _actor
	_on_floor = actor.is_on_floor()

func tick_dash_cooldown(_delta: float) -> void:
	if _dash_cooldown_timer > 0.0:
		_dash_cooldown_timer = maxf(_dash_cooldown_timer - _delta, 0.0)

func is_dashing() -> bool:
	return _is_dashing

func try_start_dash() -> bool:
	if _is_dashing:
		return false
	if not Input.is_key_pressed(KEY_R):
		return false
	if _dash_cooldown_timer > 0.0:
		return false
	if not actor.is_on_floor():
		return false

	start_dash()
	return true

func start_dash() -> void:
	_is_dashing = true
	_dash_timer = _dash_duration
	_dash_cooldown_timer = _dash_cooldown

	# Play dash animation
	actor._character_texture.play("dash_move")

	# Dash direction
	var dir = -1.0 if actor._character_texture.flip_h else 1.0
	actor.velocity.x = dir * _dash_speed
	actor.velocity.y = 0

	# VFX
	global.spawn_ghost(actor._character_texture)
	# Spawna a poeira no pé (ajuste o Vector2 se necessário, ex: Vector2(0, 16))
	global.spawn_dash_dust(actor.global_position + Vector2(0, 10), actor._character_texture.flip_h)

	_dash_ghost_timer = 0.05

func process_dash(_delta: float) -> void:
	_dash_timer -= _delta
	actor.velocity.y = 0

	_dash_ghost_timer -= _delta
	if _dash_ghost_timer <= 0.0:
		_dash_ghost_timer = 0.05
		global.spawn_ghost(actor._character_texture)

	if _dash_timer <= 0.0:
		_is_dashing = false
		actor.velocity.x = 0

func vertical_movement(_delta: float, allow_jump: bool = true) -> void:
	if actor.is_on_floor():
		if not _on_floor:
			global.spawn_effect("res://visual_effects/dust_particles/fall/fall_effect.tscn",
			Vector2(0, 11), actor.global_position, false)
			if not actor._on_knockback and actor.is_in_state("normal"):
				actor._character_texture.action_animation("land")
				actor.set_physics_process(false)
			_on_floor = true

		_jump_count = 0

	if not actor.is_on_floor():
		_on_floor = false
		actor.velocity += actor.get_gravity() * _delta

	if allow_jump and actor.is_in_state("normal") and Input.is_action_just_pressed("jump") and (_jump_count < 2):
		actor.velocity.y = _jump_velocity
		_jump_count += 1
		global.spawn_effect("res://visual_effects/dust_particles/jump/jump_effect.tscn",
		Vector2(0, 11), actor.global_position, actor._character_texture.flip_h)

	if allow_jump and Input.is_action_just_released("jump") and actor.velocity.y < 0:
		actor.velocity.y *= 0.5

func horizontal_movement(allow_input: bool = true) -> void:
	if actor._on_knockback:
		actor.velocity.x = lerpf(actor.velocity.x, 0.0, 0.1)
		return

	if not allow_input:
		actor.velocity.x = move_toward(actor.velocity.x, 0, _speed)
		return

	var _direction := Input.get_axis("move_left", "move_right")
	if _direction:
		actor.velocity.x = _direction * _speed
		return

	actor.velocity.x = move_toward(actor.velocity.x, 0, _speed)

func process_standard(_delta: float) -> void:
	vertical_movement(_delta, true)
	horizontal_movement(true)
	actor.move_and_slide()
	actor._character_texture.animate(actor.velocity)

func process_hit(_delta: float) -> void:
	vertical_movement(_delta, false)
	horizontal_movement(false)
	actor.move_and_slide()
	actor._character_texture.animate(actor.velocity)
