extends Node

class_name CharacterStateMachine

var actor: BaseCharacter
var _states: Dictionary = {}
var _current_state: CharacterState
var _current_state_name: String = ""

func setup(_owner: BaseCharacter, _state_scripts: Dictionary) -> void:
	actor = _owner
	for _name in _state_scripts.keys():
		var script_ref = _state_scripts[_name]
		var state: CharacterState = script_ref.new()
		state.actor = actor
		state.fsm = self
		add_child(state)
		_states[_name] = state

func change_state(_name: String) -> void:
	if _current_state_name == _name:
		return
	if _current_state != null:
		_current_state.exit()
	var prev := _current_state
	_current_state = _states.get(_name)
	_current_state_name = _name
	if _current_state != null:
		_current_state.enter(prev)

func is_in_state(_name: String) -> bool:
	return _current_state_name == _name

func handle_input(_event: InputEvent) -> void:
	if _current_state != null:
		_current_state.handle_input(_event)

func physics_process(_delta: float) -> void:
	if _current_state != null:
		_current_state.physics_process(_delta)
