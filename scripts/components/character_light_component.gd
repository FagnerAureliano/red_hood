extends PointLight2D
class_name CharacterLightComponent

func _ready() -> void:
	_setup_light_properties()
	_setup_environment()

func _setup_light_properties() -> void:
	var light_color = Color(1.0, 1.0, 1.0, 1.0)
	var light_energy = 1.5
	var light_texture_size = 512
	
	var _texture = GradientTexture2D.new()
	_texture.width = light_texture_size
	_texture.height = light_texture_size
	
	# Radial fill
	_texture.fill = GradientTexture2D.FILL_RADIAL
	_texture.fill_from = Vector2(0.5, 0.5)
	_texture.fill_to = Vector2(1.0, 0.5)
	
	var _gradient = Gradient.new()
	_gradient.colors = PackedColorArray([
		Color(1, 1, 1, 1), 
		Color(0.1, 0.1, 0.1, 0)
	])
	_gradient.offsets = PackedFloat32Array([0.0, 0.7]) 
	
	_texture.gradient = _gradient
	
	self.texture = _texture
	self.energy = light_energy
	self.shadow_enabled = true
	self.texture_scale = 1.5
	self.range_layer_min = -100

func _setup_environment() -> void:
	# character is parent
	var character = get_parent()
	if not character: return
	
	# level is character's parent
	var level = character.get_parent()
	if level:
		_apply_modulate_to_node(level)
			
		for child in level.get_children():
			if child is ParallaxBackground:
				_apply_modulate_to_node(child)
				
func _apply_modulate_to_node(node: Node) -> void:
	var has_modulate = false
	for child in node.get_children():
		if child is CanvasModulate:
			has_modulate = true
			break
	
	if not has_modulate:
		var modulate = CanvasModulate.new()
		modulate.color = Color(0.02, 0.02, 0.05, 1)
		node.call_deferred("add_child", modulate)
