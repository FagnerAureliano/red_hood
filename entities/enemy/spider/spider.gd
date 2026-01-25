extends BaseEnemy
class_name Spider

const comet_drop_scene: PackedScene = preload("res://collectables_by_drop/comet_drop/comet_drop.tscn")

var _drop_rng := RandomNumberGenerator.new()
@export var _spider_health: int = 40


func _attack() -> void:
	if _get_attack_target() == null:
		return
	_enemy_texture.action_animate("attack")


func _ready() -> void:
	super ()
	_enemy_health = _spider_health
	_drop_rng.randomize()


func _drop_items() -> void:
	var drop := comet_drop_scene.instantiate() as CometDrop
	if drop == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	parent.call_deferred("add_child", drop)
	drop.call_deferred("set_global_position", global_position)
	drop.call_deferred("add_collision_exception_with", self)
	var side := _drop_rng.randf_range(80.0, 140.0)
	if _drop_rng.randf() < 0.5:
		side = - side
	drop.call_deferred("kick", Vector2(side, -140.0))
