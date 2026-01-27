extends Line2D

func _ready() -> void:
	# Configuração visual (sem assets externos)
	default_color = Color.WHITE 
	texture_mode = Line2D.LINE_TEXTURE_NONE
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	
	# Desenha o formato do arco (pequeno inicialmente)
	clear_points()
	
	# Randomização do formato do corte
	var rng = RandomNumberGenerator.new()
	
	# Parâmetros para definir o arco (Formato de lua/foice)
	var arc_width = rng.randf_range(12.0, 16.0)  # Largura horizontal
	var arc_depth = rng.randf_range(6.0, 10.0)   # Profundidade da curva
	var steps = 10 # Resolução da curva (mais pontos = mais suave)
	
	for i in range(steps + 1):
		var t = float(i) / float(steps) # Vai de 0.0 a 1.0
		
		# Interpolação Linear no eixo X (comprimento do corte)
		var x = lerpf(-arc_width, arc_width, t)
		
		# Curva quadrática no eixo Y para formar o arco (Parábola)
		# O centro (t=0.5) fica em Y=0, as pontas recuam para Y negativo
		var t_norm = (t - 0.5) * 2.0 # Mapeia de -1 a 1
		var y = (t_norm * t_norm) * -arc_depth
		
		add_point(Vector2(x, y))

	# Pequena rotação aleatória extra para não ficar sempre igual
	rotation_degrees += rng.randf_range(-20, 20)
	
	# Define a espessura para parecer uma lâmina (Fino nas pontas, grosso no meio)
	width = 15.0
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))   # Começo fino
	curve.add_point(Vector2(0.5, 1)) # Meio grosso
	curve.add_point(Vector2(1, 0))   # Fim fino
	width_curve = curve
	
	z_index = 10 # Garante que apareça na frente
	
	# Animação executada via código (Tween)
	var tween = create_tween()
	
	# 1. Escala o corte para frente (efeito de movimento)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# 2. Ao mesmo tempo, faz desaparecer (fade out)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	
	# 3. Deleta o nó ao terminar
	tween.tween_callback(queue_free)
