extends CollectableComponent
class_name CollectableBow

func _consume(_character: BaseCharacter) -> void:
	print("Collected Bow")
	_character.update_archer_state(true)
	queue_free()