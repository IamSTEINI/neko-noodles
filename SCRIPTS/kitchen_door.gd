extends Node2D

@onready var door_2: AnimatedSprite2D = $"DOOR 2"
@onready var door_1: AnimatedSprite2D = $"DOOR 1"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		door_1.play("DOOR LEFT OPEN")
		door_2.play("DOOR RIGHT OPEN")
	pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		door_1.play("DOOR LEFT CLOSE")
		door_2.play("DOOR RIGHT CLOSE")
	pass
