extends Container

func _process(delta: float) -> void:
	if(Globals.buildMode):
		visible = true
		position = get_global_mouse_position()
	else:
		visible = false

func _on_button_pressed() -> void:
	Globals.buildMode = !Globals.buildMode
	Globals.log("Building mode: "+str(Globals.buildMode))
