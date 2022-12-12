
## A finite state machine.
##
## Add [AfsmState]s as children to this node.
## 
## [br] TODO: Proper documentation for [Afsm]

extends Node
class_name Afsm

## The default [AfsmState] that this machine will start with.
## 	[br] Can also be changed in the editor at runtime for debugging.
@export_node_path(Node)
var default_state:NodePath :
	set(v):
		default_state = v
		if is_inside_tree():
			to_state(get_node(default_state) as AfsmState)

## This machine's current state.
var current_state:AfsmState = null
## Is [code]true[/code] if this state machine is changing states next
## frame. [color=pink]DO NOT MODIFY.[/color]
var _is_changing_state:= false

func _ready() -> void:
	if default_state:
		to_state(get_node(default_state) as AfsmState)
		

## Switches this machine to a new state.
## 	[br] Any calls to this function after it was already called in a
## frame will be ignored until the next frame.
## 	[br]
## 	[br] [b][color=pink]Errors if[/color][/b]
## 	[br] - [code]state[/code] is [code]null[/code].
## 	[br] - [code]state[/code] is not an ancestral child of this state machine.
func to_state(state:AfsmState) -> void:
	if _is_changing_state:
		return
	_to_state.bind(state).call_deferred()
	_is_changing_state = true


## Do not call directly, use [method to_state] instead.
func _to_state(state:AfsmState) -> void:
	if state == null:
		_is_changing_state = false
		return
	
	assert(state.afsm == self)
	
	var last_state:= current_state
	current_state = state
	
	if last_state:
		last_state._pre_exit_state(current_state)
	
	current_state._pre_enter_state(last_state)
	
	_is_changing_state = false
