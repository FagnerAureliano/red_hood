extends CharacterState

class_name CharacterDeadState

func enter(_prev_state: CharacterState) -> void:
	actor.set_physics_process(false)

func handle_input(_event: InputEvent) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass
