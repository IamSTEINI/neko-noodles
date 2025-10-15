extends TextureRect

func _process(delta: float) -> void:
	$RichTextLabel.text = str(Globals.restaurant_rating)
