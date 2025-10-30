extends Node2D

var skip: bool = false
var typing: bool = false
var queue: Array[String] = []
var speaking: bool = false

func _ready() -> void:
	$CanvasLayer/Speakbubble.hide()
	
func type_writer(text: String, speed: int = 30) -> void:
	$Talking.play()
	typing = true
	skip = false
	$CanvasLayer/Speakbubble/Text.text = ""
	var textt = $CanvasLayer/Speakbubble/Text
	for i in range(text.length()):
		if skip:
			textt.text = text
			break
		textt.text += text[i]
		await get_tree().create_timer(speed / 1000.0).timeout

	typing = false
	$Talking.stop()
	
func say(text: String) -> void:
	queue.append(text)
	if not speaking:
		_process_queue()
	await _wait_until_done()

func _wait_until_done() -> void:
	while speaking:
		await get_tree().process_frame

func _process_queue() -> void:
	speaking = true
	var bubble = $CanvasLayer/Speakbubble
	var orig_pos = 870
	bubble.show()
	var tween_in = create_tween()
	$CanvasLayer/Speakbubble/Text.text = ""
	bubble.modulate.a = 0.5
	bubble.position.y = orig_pos + 120
	tween_in.tween_property(bubble, "modulate:a", 1.0, 0.1)
	tween_in.tween_property(bubble, "position:y", orig_pos, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween_in.finished
	
	while queue.size() > 0:
		skip = false
		var current_text = queue.pop_front()
		
		$CanvasLayer/Speakbubble/EmmaNya.play("default")
		await type_writer(current_text, 20)
		$CanvasLayer/Speakbubble/EmmaNya.stop()
		
		while not skip:
			await get_tree().process_frame
		
		skip = false
		
	var tween_out = create_tween()
	tween_out.tween_property(bubble, "modulate:a", 0.0, 0.1)
	tween_out.tween_property(bubble, "position:y", orig_pos + 150, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween_out.finished
	$CanvasLayer/Speakbubble.hide()
	speaking = false
	
func _on_skip_pressed() -> void:
	$Click.play()
	if typing:
		skip = true
	else:
		skip = true
		
func show_tip(indx: int) -> void:
	$CanvasLayer/TipBar.show()
	for child in $CanvasLayer/TipBar.get_children():
		child.hide()
	if $CanvasLayer/TipBar.find_child("Tip"+str(indx)) != null:
		$CanvasLayer/TipBar.find_child("Tip"+str(indx)).show()
	else:
		$CanvasLayer/TipBar.hide()
