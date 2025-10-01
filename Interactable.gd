extends Node2D

@export var text: String = ""
@export var interact_key: Key = KEY_E
@export var border_color: Color = Color("#FF0000")
@export var can_interact: bool = true
var start_pos = null
var key_was_pressed = false
var player_body = null
signal player_entered(body)
signal player_exited(body)
signal interacted(body)


func interact():
	var end_pos = start_pos - Vector2(0, 50)
	var tween = create_tween()
	
	tween.tween_property($RichTextLabel, "position", end_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($RichTextLabel, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tween.tween_callback($RichTextLabel.hide)
	tween.tween_callback(func(): 
		$RichTextLabel.position = start_pos
		$RichTextLabel.modulate.a = 1.0
	)
	emit_signal("interacted", player_body)
	
func _process(delta: float) -> void:
	if can_interact && player_body != null:
		var key_is_pressed = Input.is_physical_key_pressed(interact_key)
		
		if key_is_pressed and not key_was_pressed:
			interact()
		
		key_was_pressed = key_is_pressed

func _ready() -> void:
	$RichTextLabel.visible = false
	start_pos = $RichTextLabel.position
	var stylebox = StyleBoxFlat.new()
	stylebox.border_color = border_color
	stylebox.border_width_left = 2
	stylebox.bg_color = Color("#00000067")
	stylebox.set_corner_radius_all(5)
	$RichTextLabel.add_theme_stylebox_override("normal", stylebox)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		player_body = body
		emit_signal("player_entered", body)
		var key_name = OS.get_keycode_string(interact_key)
		$RichTextLabel.text = " [" + key_name + "] " + text
		if(can_interact):
			$RichTextLabel.visible = true
		pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		emit_signal("player_exited", body)
		player_body = null
		$RichTextLabel.visible = false
		pass
