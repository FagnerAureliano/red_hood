extends Node2D

@export_category("Settings")
@export var line_color: Color = Color.WHITE
@export var line_thickness: float = 2.0
@export var scale_size: float = 1.3
@export var min_radius_base: float = 6.0
@export var max_radius_base: float = 28.0

func _ready() -> void:
	# Garante que seja desenhado no topo de tudo
	z_index = 20
	
	# Força o _draw ser chamado
	queue_redraw()
	
	# Animação de "Pop" e Desaparecimento
	var tween = create_tween()
	
	# Começa pequeno e expande rápido (Explosão)
	scale = Vector2(0.1, 0.1)
	tween.tween_property(self, "scale", Vector2(scale_size, scale_size), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Rotaciona aleatoriamente para variar
	rotation_degrees = randf_range(0, 360)
	
	# Apaga (fade out) rápido logo após expandir
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.1).set_delay(0.1)
	
	# Deleta ao terminar
	tween.tween_callback(queue_free)

func _draw() -> void:
	var rng = RandomNumberGenerator.new()
	var points = PackedVector2Array()
	
	# Configurações para ficar parecido com o desenho (Spikes irregulares em círculo)
	var spikes = rng.randi_range(6, 9) # Entre 6 e 9 pontas
	
	# Gera os pontos polares
	for i in range(spikes * 2):
		var angle = (float(i) / float(spikes * 2)) * TAU
		var direction = Vector2.from_angle(angle)
		var radius = 0.0
		
		if i % 2 == 0:
			# É uma ponta externa (longa e irregular)
			radius = rng.randf_range(max_radius_base * 0.7, max_radius_base * 1.4)
		else:
			# É um vale interno (perto do centro)
			radius = rng.randf_range(min_radius_base * 0.8, min_radius_base * 1.5)
			
		points.append(direction * radius)
	
	# Fecha o polígono conectando o último ponto ao primeiro
	points.append(points[0])
	
	# Desenha apenas o contorno (Polyline) com espessura variável
	# A imagem mostra um traço branco.
	draw_polyline(points, line_color, line_thickness, true)
