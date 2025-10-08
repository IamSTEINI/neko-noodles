extends ColorRect

signal clicked_slot(index)

func _on_mouse_entered() -> void:
	self.color = Color("00000090")


func _on_mouse_exited() -> void:
	self.color = Color("#00000070")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		var parent = get_parent()
		if parent:
			var index = get_parent().get_children().find(self)
			emit_signal("clicked_slot", index)
