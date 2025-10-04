extends Panel

func _process(delta: float) -> void:
	var fmtime: String = Globals.get_ingame_time_formatted()
	$RichTextLabel.text = fmtime
