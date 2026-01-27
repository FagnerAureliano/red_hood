extends Node

class_name CharacterState

var actor: BaseCharacter
var fsm: CharacterStateMachine

func enter(_prev_state: CharacterState) -> void:
	pass

func exit() -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass
