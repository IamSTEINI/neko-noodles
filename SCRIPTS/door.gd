extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.play("DOOR CLOSE")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if $AnimatedSprite2D.animation != "DOOR OPEN":
		$AnimatedSprite2D.play("DOOR OPEN")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if $AnimatedSprite2D.animation != "DOOR CLOSE":
		$AnimatedSprite2D.play("DOOR CLOSE")
