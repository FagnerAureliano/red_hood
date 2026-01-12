extends CollectableComponent
class_name CollectableKnife

func _consume(_character: BaseCharacter) -> void:
	print("Collected Knife")
	_character.update_knife_state(true)
	queue_free()
