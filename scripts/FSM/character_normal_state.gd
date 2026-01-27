extends CharacterState

class_name CharacterNormalState

func handle_input(_event: InputEvent) -> void:
	# Don't buffer clicks: only accept a new attack when the previous action finished.
	if actor._character_texture != null and actor._character_texture.is_in_action():
		return

	if actor._has_bow and _event.is_action_pressed("archer_attack"):
		actor._bow_attack()
		fsm.change_state("attack")
		return

	if actor._has_knife and _event.is_action_pressed("knife_attack"):
		actor.knife_attack()
		fsm.change_state("attack")
		return

	if actor._has_axe and _event.is_action_pressed("axe_attack"):
		actor.axe_attack()
		fsm.change_state("attack")
		return

func physics_process(_delta: float) -> void:
	actor._tick_dash_cooldown(_delta)

	# Verifica input ANTES e se não estiver dando dash
	if not actor._is_dashing and Input.is_key_pressed(KEY_R) and actor._dash_cooldown_timer <= 0.0 and actor.is_on_floor():
		actor._start_dash()
		fsm.change_state("dash")
		actor._process_dash(_delta)
		actor.move_and_slide()
		return

	actor._vertical_movement(_delta)
	actor._horizontal_movement()
	actor.move_and_slide()
	actor._character_texture.animate(actor.velocity)
