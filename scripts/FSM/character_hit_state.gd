extends CharacterState

class_name CharacterHitState

func handle_input(_event: InputEvent) -> void:
	# Ignore input while hit.
	pass

func physics_process(_delta: float) -> void:
	actor._tick_dash_cooldown(_delta)
	actor._vertical_movement(_delta)
	actor._horizontal_movement()
	actor.move_and_slide()
	actor._character_texture.animate(actor.velocity)
