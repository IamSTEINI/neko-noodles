extends Panel

func _process(delta: float) -> void:
	$RichTextLabel.text = str(Globals.day)
