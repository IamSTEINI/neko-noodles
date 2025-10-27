extends Node2D

signal new_day_started(day: int)

func _ready() -> void:
	$CanvasLayer.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_released("devmode"):
		$CanvasLayer.visible = !$CanvasLayer.visible


func _on_time_skip_button_down() -> void:
	Engine.time_scale = 20


func _on_time_skip_button_up() -> void:
	Engine.time_scale = 1


func _on_new_day_pressed() -> void:
	emit_signal("new_day_started", Globals.day)
