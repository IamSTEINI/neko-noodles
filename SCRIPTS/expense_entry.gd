extends RichTextLabel
@export var reason: String = ""
@export var amount: int = 0

func _ready() -> void:
	text = str(amount)
	$reason.text = reason
	if amount > 0:
		self.add_theme_color_override("default_color", Color("#60a200"))
