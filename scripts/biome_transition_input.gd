extends Node

const MIN_DISMISS_MS := 450

func _ready() -> void:
	# Only listen for input while the SceneTree is paused.
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	var main: Node = get_parent()
	if main == null:
		return
	if not bool(main.get("biome_transition_active")):
		return
	if bool(main.get("biome_transition_dismissing")):
		return
	var started_ms: int = int(main.get("biome_transition_started_ms"))
	if (Time.get_ticks_msec() - started_ms) < MIN_DISMISS_MS:
		return

	var should_dismiss: bool = false
	if event is InputEventKey:
		var key_event: InputEventKey = event
		should_dismiss = key_event.pressed and not key_event.echo
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		should_dismiss = mouse_event.pressed
	elif event is InputEventJoypadButton:
		var pad_event: InputEventJoypadButton = event
		should_dismiss = pad_event.pressed

	if should_dismiss:
		main.call("_dismiss_biome_transition_card")
		get_viewport().set_input_as_handled()
