extends Node2D

var start_pos: Vector2

func _ready() -> void:
	$RichTextLabel.visible = false
	$text.hide()
	start_pos = $RichTextLabel.position

func say(text: String) -> void:
	$text.show()
	$Talking.play()
	$text.text = ""
	
	for i in range(text.length()):
		$text.text += text[i]
		await get_tree().create_timer(0.05).timeout
	
	await get_tree().create_timer(2.0).timeout
	$text.hide()
	$Talking.stop()


func _on_buytrigger_body_entered(body: Node2D) -> void:
	if not body.has_node("ItemSlot"):
		return
	var item_slot = body.get_node("ItemSlot")
	if item_slot.get_child_count() == 0:
		return
	var main_item = item_slot.get_child(0)
	if not main_item.has_meta("buy_price"):
		return
	
	var price = main_item.get_meta("buy_price")
	var backpack_items = []
	
	if Globals.bought_backpack and body.has_node("BackpackSlot"):
		for item in body.get_node("BackpackSlot").get_children():
			if item.has_meta("buy_price"):
				price += item.get_meta("buy_price")
				backpack_items.append(item)
	
	if Globals.money<price:
		return
	$RichTextLabel.visible = true
	say("Thanks for shopping!")
	$RichTextLabel.text = "- " + str(price)
	$Collect_Sound.play(0.07)
	Globals.money = Globals.money - price
	Expenses.add_transaction("Shopping", -1 * price)
	var end_pos = start_pos - Vector2(0, 50)
	var tween = create_tween()
	tween.tween_property($RichTextLabel, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($RichTextLabel, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		$RichTextLabel.hide()
		$RichTextLabel.position = start_pos
		$RichTextLabel.modulate.a = 1.0
		main_item.remove_meta("buy_price")
		for item in backpack_items:
			item.remove_meta("buy_price")
	)
