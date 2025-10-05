extends Node2D

@export var amount: int = 0
var start_pos: Vector2
var used: bool = false

func _ready() -> void:
	$RichTextLabel.visible = false
	$RichTextLabel.text = "+" + str(amount)
	start_pos = $RichTextLabel.position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player" and not used:
		used = true
		$RichTextLabel.visible = true
		$Collect_Sound.play(0.07)
		$Sprite2D.hide()
		var end_pos = start_pos - Vector2(0, 50)
		var tween = create_tween()
		tween.tween_property($RichTextLabel, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property($RichTextLabel, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_callback(func():
			$RichTextLabel.hide()
			$RichTextLabel.position = start_pos
			$RichTextLabel.modulate.a = 1.0
			Globals.money += amount
			queue_free()
		)
