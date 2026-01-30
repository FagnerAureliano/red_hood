extends PointLight2D
class_name LightSource

@export var light_color_override: Color = Color(1.0, 0.6, 0.2, 1.0) # Cor alaranjada padrao para fogo
@export var light_scale_override: float = 1.0
@export var energy_override: float = 1.5

func _ready() -> void:
	_setup_light()

func _setup_light() -> void:
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
	self.color = light_color_override
	self.energy = energy_override
	self.shadow_enabled = true
	self.texture_scale = light_scale_override
	self.range_layer_min = -100 # Afeta o background tambem
