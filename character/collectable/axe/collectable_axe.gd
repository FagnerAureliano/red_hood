extends CollectableComponent
class_name CollectableAxe

func _consume(_character: BaseCharacter) -> void:
	print("Collected Axe")
	_character.update_axe_state(true)
	queue_free()
