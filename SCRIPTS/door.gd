extends Node2D

var npcs: int = 0

func _ready() -> void:
	$AnimatedSprite2D.play("DOOR CLOSE")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_meta("type"):
		npcs += 1
		if npcs == 1:
			if $AnimatedSprite2D.animation != "DOOR OPEN":
				$AnimatedSprite2D.play("DOOR OPEN")
				$DOOR_SOUND.play()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_meta("type"):
		npcs = max(0, npcs - 1)
		if npcs == 0:
			if $AnimatedSprite2D.animation != "DOOR CLOSE":
				$AnimatedSprite2D.play("DOOR CLOSE")
				$DOOR_SOUND.play()
