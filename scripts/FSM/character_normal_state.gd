extends CharacterState

class_name CharacterNormalState

func handle_input(_event: InputEvent) -> void:
	if actor._input_component == null:
		return
	if actor._input_component.handle_input(_event):
		fsm.change_state("attack")
		return

func physics_process(_delta: float) -> void:
	if actor._movement_component == null:
		return

	actor._movement_component.tick_dash_cooldown(_delta)

	# Verifica input ANTES e se não estiver dando dash
	if actor._movement_component.try_start_dash():
		fsm.change_state("dash")
		actor._movement_component.process_dash(_delta)
		actor.move_and_slide()
		return

	actor._movement_component.process_standard(_delta)
