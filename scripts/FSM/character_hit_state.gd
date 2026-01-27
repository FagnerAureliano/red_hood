extends CharacterState

class_name CharacterHitState

func handle_input(_event: InputEvent) -> void:
	# Ignore input while hit.
	pass

func physics_process(_delta: float) -> void:
	if actor._movement_component == null:
		return
	actor._movement_component.tick_dash_cooldown(_delta)
	actor._movement_component.process_hit(_delta)
