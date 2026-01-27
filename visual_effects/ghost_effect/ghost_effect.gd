extends Sprite2D

func _ready() -> void:
	# Torna o fantasma um pouco transparente e azulado (efeito "flash/dash")
	# Se quiser a cor original, apenas use Color(1, 1, 1, 0.8)
	modulate = Color(0.5, 0.5, 1.5, 0.8) 
	
	var tween = create_tween()
	
	# Faz desaparecer: altera o Alpha (transparência) para 0 em 0.3 segundos
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	# Deleta o objeto quando terminar
	tween.tween_callback(queue_free)

func set_ghost_properties(target_sprite: AnimatedSprite2D) -> void:
	# Copia exatamente o que o personagem está vestindo/fazendo agora
	# Nota: AnimatedSprite2D tem frames divididos internamente, então pegamos o frame atual
	# Mas Sprite2D (que esse script estende) precisa de uma textura estática.
	
	if target_sprite.sprite_frames:
		var frame_texture = target_sprite.sprite_frames.get_frame_texture(target_sprite.animation, target_sprite.frame)
		texture = frame_texture
	
	# Ajustes de transform
	flip_h = target_sprite.flip_h
	global_position = target_sprite.global_position
	scale = target_sprite.global_scale
	offset = target_sprite.offset
