extends Node

class_name CharacterCombatComponent

var actor: BaseCharacter

@export_category("Objects")
@export var _attack_combo_timer: Timer

var _has_bow: bool = false
var _has_knife: bool = false
var _has_axe: bool = false

var _knife_combo_step: int = 0
var _axe_combo_step: int = 0

var _pending_axe_vfx: bool = false
var _pending_axe_vfx_step: int = 0
var _pending_axe_vfx_offset: Vector2 = Vector2.ZERO
var _pending_axe_vfx_flip_h: bool = false

var _combo_wait_time_base: float = 0.0

func setup(_actor: BaseCharacter) -> void:
	actor = _actor
	if _attack_combo_timer == null:
		_attack_combo_timer = actor.get_node_or_null("AttackCombo") as Timer
	if _attack_combo_timer != null:
		_combo_wait_time_base = _attack_combo_timer.wait_time

func has_bow() -> bool:
	return _has_bow

func has_knife() -> bool:
	return _has_knife

func has_axe() -> bool:
	return _has_axe

func update_archer_state(_state: bool) -> void:
	_has_bow = _state

func update_knife_state(_state: bool) -> void:
	_has_knife = _state
	if _state:
		_knife_combo_step = 0

func update_axe_state(_state: bool) -> void:
	_has_axe = _state
	if _state:
		_axe_combo_step = 0

func start_attack_combo_timer(extra_time_sec: float = 0.0) -> void:
	if _attack_combo_timer == null:
		return
	if _combo_wait_time_base > 0.0:
		_attack_combo_timer.wait_time = _combo_wait_time_base + extra_time_sec
	_attack_combo_timer.start()

func bow_attack() -> void:
	if not actor.is_on_floor():
		actor._character_texture.action_animation("archer_attack")
		return
	actor.set_physics_process(false)
	actor._character_texture.action_animation("archer_attack")

func knife_attack() -> void:
	start_attack_combo_timer()

	_knife_combo_step = (_knife_combo_step % 3) + 1
	var anim_name := "attack_%d_with_knife" % _knife_combo_step
	var offset := Vector2(40, 1)
	if actor._character_texture.flip_h:
		offset.x = -offset.x

	global.spawn_effect(
		"res://visual_effects/knife/attack_%d/attack_%d.tscn" % [_knife_combo_step, _knife_combo_step],
		offset,
		actor.global_position,
		actor._character_texture.flip_h
	)

	if not actor.is_on_floor():
		actor._character_texture.action_animation(anim_name)
		return
	actor.set_physics_process(false)
	actor._character_texture.action_animation(anim_name)

func axe_attack() -> void:
	start_attack_combo_timer(0.2)
	_axe_combo_step = (_axe_combo_step % 3) + 1
	var anim_name := "attack_%d_with_axe" % _axe_combo_step
	var offset := Vector2(30, 1)
	if actor._character_texture.flip_h:
		offset.x = -offset.x

	# VFX is triggered by CharacterTexture on frame 4 (see `_on_frame_changed`).
	_pending_axe_vfx = true
	_pending_axe_vfx_step = _axe_combo_step
	_pending_axe_vfx_offset = offset
	_pending_axe_vfx_flip_h = actor._character_texture.flip_h

	if not actor.is_on_floor():
		actor._character_texture.action_animation(anim_name)
		return
	actor.set_physics_process(false)
	actor._character_texture.action_animation(anim_name)

func spawn_pending_axe_effect() -> void:
	if not _pending_axe_vfx:
		return
	_pending_axe_vfx = false

	global.spawn_effect(
		"res://visual_effects/knife/attack_%d/attack_%d.tscn" % [_pending_axe_vfx_step, _pending_axe_vfx_step],
		_pending_axe_vfx_offset,
		actor.global_position,
		_pending_axe_vfx_flip_h
	)

func spawn_bow_projectile(_facing_left: bool) -> void:
	var bow_instance := actor.throwable_bow_scene.instantiate() as CharacterBow
	if bow_instance == null:
		return

	var parent := actor.get_parent()
	if parent == null:
		return
	bow_instance.direction = Vector2(-1, 0) if _facing_left else Vector2(1, 0)
	parent.call_deferred("add_child", bow_instance)
	bow_instance.call_deferred("set_global_position", actor.global_position + Vector2(0, 0))

func reset_combo() -> void:
	_knife_combo_step = 0
	_axe_combo_step = 0
