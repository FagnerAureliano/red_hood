extends Node

class_name Global

const damage_popup_scene: PackedScene = preload("res://ui/damage_popup/damage_popup.tscn")
const impact_spark_scene: PackedScene = preload("res://visual_effects/hit_spark/hit_spark.tscn")
const slash_scene: PackedScene = preload("res://visual_effects/slash_effect/slash_effect.tscn")
const impact_lines_scene: PackedScene = preload("res://visual_effects/impact_lines/impact_lines.tscn")
const ghost_scene: PackedScene = preload("res://visual_effects/ghost_effect/ghost_effect.tscn")
const dash_dust_scene: PackedScene = preload("res://visual_effects/dash_effect/dash_dust.tscn")

var ui_inventory: InventoryUI = null

@export_category("UI")
@export var show_damage_numbers: bool = true


func spawn_effect(_path: String, _offset: Vector2, _initial_position: Vector2, _is_flipped: bool) -> void:
	var scene: PackedScene = load(_path) as PackedScene
	if scene == null:
		return

	var _effect := scene.instantiate()
	if _effect == null:
		return
	if _effect is Node2D:
		_effect.global_position = _initial_position + _offset
	elif _effect is Control:
		_effect.global_position = _initial_position + _offset
	if _effect is Object and ("flip_h" in _effect):
		_effect.flip_h = _is_flipped
	

	# get_tree().root.call_deferred("add_child", _effect)
	get_tree().current_scene.add_child(_effect)


func spawn_impact_spark(_initial_position: Vector2) -> void:
	# Partículas (Hit Spark)
	if impact_spark_scene:
		var _spark = impact_spark_scene.instantiate()
		_spark.global_position = _initial_position
		get_tree().current_scene.add_child(_spark)
	
	# Efeito de linhas estilo cartoon
	if impact_lines_scene:
		var _lines = impact_lines_scene.instantiate()
		_lines.global_position = _initial_position
		get_tree().current_scene.add_child(_lines)


func spawn_ghost(target_sprite: AnimatedSprite2D) -> void:
	# Cria o rastro do personagem (efeito flash/dash)
	if ghost_scene == null or target_sprite == null:
		return
		
	var ghost = ghost_scene.instantiate()
	get_tree().current_scene.add_child(ghost)
	
	if ghost.has_method("set_ghost_properties"):
		ghost.set_ghost_properties(target_sprite)


func spawn_dash_dust(_initial_position: Vector2, _is_flipped: bool) -> void:
	if dash_dust_scene == null:
		return
		
	var dust = dash_dust_scene.instantiate()
	dust.global_position = _initial_position
	
	# Se o char olhar pra esquerda (flip_h=true), a poeira (que vai pra trás) 
	# deve ser espelhada para ir pra direita.
	# O script dash_dust move partículas para -X (esquerda).
	# Se char olha pra Direita (flip=false): Back é Esquerda (-X). OK. Escala 1.
	# Se char olha pra Esquerda (flip=true): Back é Direita (+X). Precisa inverter. Escala -1.
	
	if _is_flipped:
		dust.scale.x = -1
	
	get_tree().current_scene.add_child(dust)


func spawn_slash(_initial_position: Vector2, _is_flipped: bool) -> void:
	if slash_scene == null:
		return
		
	var slash = slash_scene.instantiate()
	slash.global_position = _initial_position
	
	if _is_flipped:
		slash.scale.x = -1
		slash.rotation_degrees = 45 
	else:
		slash.rotation_degrees = -45
		
	get_tree().current_scene.add_child(slash)


func spawn_damage_popup(amount: int, _initial_position: Vector2, _offset: Vector2 = Vector2(0, -24)) -> void:
	if not show_damage_numbers:
		return
	var popup := damage_popup_scene.instantiate()
	if popup == null:
		return
	if popup is Object and ("amount" in popup):
		popup.amount = amount
	if popup is Control:
		popup.global_position = _initial_position + _offset
	elif popup is Node2D:
		popup.global_position = _initial_position + _offset
	get_tree().current_scene.add_child(popup)


