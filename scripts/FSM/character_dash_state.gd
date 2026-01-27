extends CharacterState

class_name CharacterDashState

func physics_process(_delta: float) -> void:
	if actor._movement_component == null:
		return
	actor._movement_component.process_dash(_delta)
	actor.move_and_slide()
	if not actor._movement_component.is_dashing():
		fsm.change_state("normal")
