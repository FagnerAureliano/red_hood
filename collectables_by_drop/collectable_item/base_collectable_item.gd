extends RigidBody2D
class_name BaseCollectableItem

@export_category("Visual")
@export var trail_length: int = 20
@export var trail_width: float = 2.5
@export var glow_radius: float = 3.0
@export var glow_color: Color = Color(1.0, 1.0, 1.0, 0.9)
@export var tail_color: Color = Color(1.0, 1.0, 1.0, 0.45)
@export var tail_particle_amount: int = 18
@export var tail_particle_lifetime: float = 0.35
@export var tail_particle_size: float = 2.2

@export_category("Physics")
@export var min_kick_impulse: float = 80.0
@export var max_kick_impulse: float = 140.0
@export var kick_up_impulse: float = -140.0

@export_category("Loot")
@export var loot_table: Array[String] = []

var _drop_data: Dictionary = {}
var _trail_points: PackedVector2Array = PackedVector2Array()
var _rng := RandomNumberGenerator.new()

@onready var _trail_line: Line2D = $Trail
@onready var _tail_particles: GPUParticles2D = $TailParticles

func set_drop_data(data: Dictionary) -> void:
	_drop_data = data

func _on_collectable_area_body_entered(body: Node2D) -> void:
	if body is BaseCharacter:
		_collect_items(body)

func _collect_items(character: BaseCharacter) -> void:
	if _drop_data.is_empty():
		queue_free()
		return
		
	# Visual feedback
	global.spawn_effect("res://visual_effects/dust_particles/jump/jump_effect.tscn", Vector2.ZERO, global_position, false)

	var _inventory = character.get_node_or_null("CharacterInventory")
	if _inventory == null:
		return
		
	# Iterate through all possible drops and roll for each
	for item_key in _drop_data:
		var item_info = _drop_data[item_key]
		var chance = item_info.get("spawn_chance", 0.0)
		
		if _rng.randf() <= chance:
			# Construct the item dictionary expected by inventory
			# The inventory expects { "item_name": { ...data... } }
			var item_to_add = { item_key: item_info }
			_inventory.add_item(item_to_add)
			print("Collected item: ", item_key)
			
	queue_free()

func _ready() -> void:
	_rng.randomize()
	if _trail_line != null:
		_trail_line.width = trail_width
		_trail_line.default_color = tail_color
	if _tail_particles != null:
		_tail_particles.amount = tail_particle_amount
		_tail_particles.lifetime = tail_particle_lifetime
		if _tail_particles.process_material is ParticleProcessMaterial:
			var _particle_mat := _tail_particles.process_material as ParticleProcessMaterial
			_particle_mat.color = tail_color
			_particle_mat.scale_min = tail_particle_size * 0.6
			_particle_mat.scale_max = tail_particle_size

	queue_redraw()

func _physics_process(_delta: float) -> void:
	_update_trail()

func _update_trail() -> void:
	_trail_points.append(global_position)
	if _trail_points.size() > trail_length:
		_trail_points.remove_at(0)

	if _trail_line != null:
		var local_points := PackedVector2Array()
		for point in _trail_points:
			local_points.append(to_local(point))
		_trail_line.points = local_points

func _draw() -> void:
	# Glow core
	draw_circle(Vector2.ZERO, glow_radius, glow_color)
	# Soft outer glow
	draw_circle(Vector2.ZERO, glow_radius * 1.8, Color(glow_color, glow_color.a * 0.35))

func kick(impulse: Vector2 = Vector2.ZERO) -> void:
	if impulse == Vector2.ZERO:
		var side := _rng.randf_range(min_kick_impulse, max_kick_impulse)
		if _rng.randf() < 0.5:
			side = - side
		impulse = Vector2(side, kick_up_impulse)
	apply_impulse(impulse)
