extends TextureRect

func _process(_delta: float) -> void:
	if Globals.tutarrow_pos != Vector2(0,42):
		position = Globals.tutarrow_pos
		show()
	else:
		hide()
