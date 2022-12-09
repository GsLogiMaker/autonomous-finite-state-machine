
## A state for [Afsm].
## 
## [br]
## 
## [b][color=yellow]Warning:[/color][/b] utilizes [method set_process], 
## [method set_physics_process], and [method set_process_input] to handle
## state activation and deactivation.
##
## [br][br]
##
## [b][color=cyan]TODO:[/color][/b] Proper documentation for [AfsmState]

extends Node
class_name AfsmState

## Flags for recording if a state uses various processes. (For internal use.)
enum ProcessFlags {
	PROCESS = 1<<0,
	PROCESS_INT = 1<<1,
	PHYSICS = 1<<2,
	PHYSICS_INT = 1<<3,
	INPUT = 1<<4,
	UNHANDLED_INPUT = 1<<5,
	UNHANDLED_KEY = 1<<6,
	SHORTCUT = 1<<7,
}

## This state's master [Afsm].
var afsm:Afsm = null

## Stores the processes that this state uses.
## [color=pink]DO NOT MODIFY.[/color]
var _process_flags:= 0
## Is [code]true[/code] if this state is currently active. Use
## [method is_active] to check if this state is active.
## [color=pink]DO NOT MODIFY.[/color]
var _active:= false

func _ready():
	afsm = find_afsm()
	
	assert(afsm, \
		"An 'AfsmState' at '%s' requires an 'Afsm' as an ancestral parent." % get_path() \
	)
	
	if is_processing():
		_process_flags |= ProcessFlags.PROCESS
	if is_processing_internal():
		_process_flags |= ProcessFlags.PROCESS_INT
	if is_physics_processing():
		_process_flags |= ProcessFlags.PHYSICS
	if is_physics_processing_internal():
		_process_flags |= ProcessFlags.PHYSICS_INT
	if is_processing_input():
		_process_flags |= ProcessFlags.INPUT
	if is_processing_unhandled_input():
		_process_flags |= ProcessFlags.UNHANDLED_INPUT
	if is_processing_unhandled_key_input():
		_process_flags |= ProcessFlags.UNHANDLED_KEY
	if is_processing_shortcut_input():
		_process_flags |= ProcessFlags.SHORTCUT
	
	_pre_exit_state(null, false)
	

## Called when the parent [Afsm] switches to this state, before
## [member _enter_state].
## 	[br]
## 	[br] [color=pink]DO NOT OVERRIDE[/color].
## 	[br] [color=pink]DO NOT CALL DIRECTLY.[/color]
func _pre_enter_state(from:AfsmState) -> void:
	_active = true
	set_process(_process_flags & ProcessFlags.PROCESS)
	set_process_internal(_process_flags & ProcessFlags.PROCESS_INT)
	set_physics_process(_process_flags & ProcessFlags.PHYSICS)
	set_physics_process_internal(_process_flags & ProcessFlags.PHYSICS_INT)
	set_process_input(_process_flags & ProcessFlags.INPUT)
	set_process_unhandled_input(_process_flags & ProcessFlags.UNHANDLED_INPUT)
	set_process_unhandled_key_input(_process_flags & ProcessFlags.UNHANDLED_KEY)
	set_process_shortcut_input(_process_flags & ProcessFlags.SHORTCUT)
	
	_enter_state(from)


## Called when the parent [Afsm] switches away from this state, before
## [member _exit_state].
## 	[br]
## 	[br] [color=pink]DO NOT OVERRIDE[/color]
## 	[br] [color=pink]DO NOT CALL DIRECTLY.[/color]
func _pre_exit_state(to:AfsmState, call_exit:=true) -> void:
	_active = false
	set_process(false)
	set_process_internal(false)
	set_physics_process(false)
	set_physics_process_internal(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	set_process_shortcut_input(false)
	
	if call_exit:
		_exit_state(to)


## Called when the parent [Afsm] switches to this state.
## 	[br] Override to provide a state with functionality upon being entered.
## 	[br]
## 	[br] [color=pink]DO NOT CALL DIRECTLY.[/color]
func _enter_state(from:AfsmState) -> void:
	pass


## Called when the parent [Afsm] switches away from this state.
## 	[br] Override to provide a state with functionality upon being exited.
## 	[br]
## 	[br] [color=pink]DO NOT CALL DIRECTLY.[/color]
func _exit_state(to:AfsmState) -> void:
	pass


## Switches this state's machine to a new state.
## 	[br] Any calls to this function after it was already called in a
## 	frame will be ignored until the next frame.
## 	[br]
## 	[br] [b][color=pink]Errors if[/color][/b]
## 	[br] - [code]state[/code] is [code]null[/code].
## 	[br] - [code]state[/code] is not an ancestral
## child of this state's machine.
func to_state(state:AfsmState) -> void:
	afsm.to_state(state)


## Returns this state's master [Afsm] node in the tree.
## 	[br] Returns [code]null[/code] if the state is not an acestral child of a
## [Afsm].
func find_afsm() -> Afsm:
	var p:= get_parent()
	while true:
		if p is Afsm or p == null:
			return p
			
		p = p.get_parent()
	
	return null


## Returns [code]true[/code] if this state is currently active.
func is_actve() -> bool:
	return _active
