extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.frame = 0

func _on_interactable_interacted(body: Node2D) -> void:
	Globals.buildMode = false
	if body.has_meta("type"):
		if body.get_meta("type") == "player":
			if body.has_method("show_arcade"):
				body.show_arcade()
				$AudioStreamPlayer2D.play()
				$AnimatedSprite2D.play()

func _on_interactable_player_exited(body: Node2D) -> void:
	if body.has_meta("type"):
		if body.get_meta("type") == "player":
			if body.has_method("hide_arcade"):
				body.hide_arcade()
				$AnimatedSprite2D.stop()
				$AudioStreamPlayer2D.stop()
				$AnimatedSprite2D.frame = 0
