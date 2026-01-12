extends CollectableComponent
class_name CollectableSword

func _consume(_character: BaseCharacter) -> void:
	print("Collected Sword")
	_character.update_sword_state(true)
	queue_free()
