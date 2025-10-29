extends Node

const DPI = 400
const DEADZONE = 0.01

var left_pressed := false
var right_pressed := false

func _physics_process(delta: float) -> void:
	var left_stick_vector = Input.get_vector("vm_left", "vm_right", "vm_up", "vm_down")
	
	if left_stick_vector.length() > DEADZONE:
		get_viewport().warp_mouse(get_viewport().get_mouse_position() + left_stick_vector * DPI * delta)
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("left_mouse_button") and not left_pressed:
		left_pressed = true
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		ev.position = mouse_pos
		ev.global_position = mouse_pos
		Input.parse_input_event(ev)
	
	if Input.is_action_just_released("left_mouse_button") and left_pressed:
		left_pressed = false
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = false
		ev.position = mouse_pos
		ev.global_position = mouse_pos
		Input.parse_input_event(ev)
	
	if Input.is_action_just_pressed("right_mouse_button") and not right_pressed:
		right_pressed = true
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_RIGHT
		ev.pressed = true
		ev.position = mouse_pos
		ev.global_position = mouse_pos
		Input.parse_input_event(ev)
	
	if Input.is_action_just_released("right_mouse_button") and right_pressed:
		right_pressed = false
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_RIGHT
		ev.pressed = false
		ev.position = mouse_pos
		ev.global_position = mouse_pos
		Input.parse_input_event(ev)
