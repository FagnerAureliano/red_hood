extends CharacterState

class_name CharacterDashState

func physics_process(_delta: float) -> void:
	actor._process_dash(_delta)
	actor.move_and_slide()
	if not actor._is_dashing:
		fsm.change_state("normal")
