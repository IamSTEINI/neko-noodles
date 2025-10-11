extends Node2D

var start_pos: Vector2

func _ready() -> void:
	$RichTextLabel.visible = false
	start_pos = $RichTextLabel.position
	
func _on_buytrigger_body_entered(body: Node2D) -> void:
	if body.has_node("ItemSlot"):
		if body.get_node("ItemSlot").get_child_count() == 1:
			var price = body.get_node("ItemSlot").get_child(0).get_meta("buy_price")
			if price != null:
				$RichTextLabel.visible = true
				$RichTextLabel.text = "- "+str(body.get_node("ItemSlot").get_child(0).get_meta("buy_price"))
				$Collect_Sound.play(0.07)
				Globals.money = Globals.money - price
				var end_pos = start_pos - Vector2(0, 50)
				var tween = create_tween()
				tween.tween_property($RichTextLabel, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween.tween_property($RichTextLabel, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				tween.tween_callback(func():
					$RichTextLabel.hide()
					$RichTextLabel.position = start_pos
					$RichTextLabel.modulate.a = 1.0
					body.get_node("ItemSlot").get_child(0).remove_meta("buy_price")
				)
