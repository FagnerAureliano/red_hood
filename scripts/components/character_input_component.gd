extends Node

class_name CharacterInputComponent

var actor: BaseCharacter

func setup(_actor: BaseCharacter) -> void:
	actor = _actor

func handle_input(_event: InputEvent) -> bool:
	# Don't buffer clicks: only accept a new attack when the previous action finished.
	if actor._character_texture != null and actor._character_texture.is_in_action():
		return false
	if actor._combat_component == null:
		return false

	if actor._combat_component.has_bow() and _event.is_action_pressed("archer_attack"):
		actor._bow_attack()
		return true

	if actor._combat_component.has_knife() and _event.is_action_pressed("knife_attack"):
		actor.knife_attack()
		return true

	if actor._combat_component.has_axe() and _event.is_action_pressed("axe_attack"):
		actor.axe_attack()
		return true

	return false
