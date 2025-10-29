extends Node2D

signal new_day_started(day: int)
signal game_lost

func _ready() -> void:
	$CanvasLayer.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_released("devmode"):
		$CanvasLayer.visible = !$CanvasLayer.visible
	
	# Testing with IJKL and U as left and O as right click
	if Input.is_action_pressed("vm_up"):
		$CanvasLayer/JoyStick.play("UP")
	elif Input.is_action_pressed("vm_down"):
		$CanvasLayer/JoyStick.play("DOWN")
	elif Input.is_action_pressed("vm_left"):
		$CanvasLayer/JoyStick.play("LEFT")
	elif Input.is_action_pressed("vm_right"):
		$CanvasLayer/JoyStick.play("RIGHT")
	else:
		$CanvasLayer/JoyStick.play("IDLE")
	
func _on_time_skip_button_down() -> void:
	Engine.time_scale = 20


func _on_time_skip_button_up() -> void:
	Engine.time_scale = 1


func _on_new_day_pressed() -> void:
	emit_signal("new_day_started", Globals.day)


func _on_game_lost_pressed() -> void:
	emit_signal("game_lost")
	pass
