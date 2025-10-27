extends Node2D

var entry_scene: PackedScene = preload("res://scenes/expense_entry.tscn")
var count_tween: Tween

func _ready() -> void:
	Globals.new_day_started.connect(_on_new_day_started)
	Dev.new_day_started.connect(_on_new_day_started)
	$BG.hide()

func _on_new_day_started(day: int) -> void:
	$BG.show()
	$AnimationPlayer.speed_scale = 1
	$"BG/DAY COUNT".text = str(day)
	$AnimationPlayer.play("NEW_DAY")
	
	var entries = Expenses.get_transactions()
	for child in $BG/MoneyCounted/GridContainer.get_children():
		if child.name != "sum":
			child.queue_free()
	
	var total = 0
	var delay = 0.0
	await get_tree().create_timer(1).timeout
	for transaction in entries:
		var entry = (entry_scene.instantiate() as RichTextLabel)
		entry.custom_minimum_size = Vector2(645, 45.0)
		entry.add_theme_font_size_override("normal_font_size", 40)
		entry.get_child(0).add_theme_font_size_override("normal_font_size", 40)
		entry.get_child(0).custom_minimum_size = Vector2(345, 45.0)
		entry.get_child(0).position = Vector2(300, 8)
		entry.reason = transaction["reason"]
		entry.amount = transaction["amount"]
		total += entry.amount
		$BG/MoneyCounted/GridContainer.add_child(entry)
		$BG/MoneyCounted/GridContainer.move_child(entry, 0)
		
		entry.modulate.a = 0.0
		entry.position.x = -250
		var tween = create_tween()
		tween.tween_property(entry, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(delay)
		tween.parallel().tween_property(entry, "position:x", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
		delay += 0.1
	animate_count(total, delay)

func animate_count(final_total: int, start_delay: float) -> void:
	if count_tween:
		count_tween.kill()
	$BG/MoneyCounted/GridContainer/sum.text = "0"
	await get_tree().create_timer(start_delay).timeout
	$CountMoney.play()
	
	count_tween = create_tween()
	count_tween.tween_method(update_count_display, 0, final_total, 2.5)
	count_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	count_tween.tween_callback(func(): set_color(final_total))

func update_count_display(value: float) -> void:
	var rounded_value = int(value)
	$BG/MoneyCounted/GridContainer/sum.text = str(rounded_value)

func set_color(total: int) -> void:
	if total < 0:
		$BG/MoneyCounted/GridContainer/sum.add_theme_color_override("default_color", Color("e40031"))
	else:
		$BG/MoneyCounted/GridContainer/sum.add_theme_color_override("default_color", Color("7aba00"))

func _on_continue_pressed() -> void:
	Expenses.clear_transactions()
	$Click.play()
	$AnimationPlayer.speed_scale = 2
	$AnimationPlayer.play_backwards("NEW_DAY")
	if count_tween:
		count_tween.kill()
