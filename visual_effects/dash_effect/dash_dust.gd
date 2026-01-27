extends Node2D

@export var count: int = 6
@export var min_size: float = 4.0
@export var max_size: float = 12.0
@export var spread_angle: float = 45.0
@export var speed_scale: float = 1.0

func _ready() -> void:
	z_index = 5 # Atrás do personagem (geralmente chars jogam no z 0 ou 10)
	
	# Criação procedural das "pedras/poeira" estilizadas
	for i in range(count):
		var shard = Polygon2D.new()
		var rng = RandomNumberGenerator.new()
		
		# Cria um formato irregular (triângulo alongado/trapézio)
		var width = rng.randf_range(min_size, max_size)
		var height = rng.randf_range(min_size * 0.5, max_size * 0.8)
		
		# Polígono apontando para "cima/trás"
		var points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(width, -height * 0.5), # Ponta direita
			Vector2(width * 0.8, height),  # Base direita
			Vector2(-width * 0.2, height * 0.8) # Base esquerda
		])
		shard.polygon = points
		shard.color = Color.WHITE
		
		# Posição inicial: espalhada um pouco na base
		shard.position = Vector2(rng.randf_range(-5, 5), rng.randf_range(-2, 2))
		
		# Rotação inicial aleatória
		shard.rotation_degrees = rng.randf_range(-30, 30)
		
		add_child(shard)
		
		# Animação individual
		var tween = create_tween()
		var duration = rng.randf_range(0.2, 0.4)
		
		# Movimento: Para trás e levemente para cima
		# Assumindo que o Node2D pai já vai ser rotacionado/escalado para a direção correta
		var move_dir = Vector2(-1, rng.randf_range(-0.5, 0.0)).normalized() # Esquerda e cima
		var move_dist = rng.randf_range(20, 40) * speed_scale
		
		tween.tween_property(shard, "position", shard.position + (move_dir * move_dist), duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		# Escala: Encolhe até sumir
		tween.parallel().tween_property(shard, "scale", Vector2.ZERO, duration).set_delay(duration * 0.2)
		
		# Cor: Fade out no final
		tween.parallel().tween_property(shard, "modulate:a", 0.0, duration * 0.5).set_delay(duration * 0.5)

	# Auto-destruição após o maior tempo possível (0.5s é seguro conforme durações acima)
	get_tree().create_timer(0.6).timeout.connect(queue_free)
