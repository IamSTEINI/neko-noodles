extends TextureRect

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	visible = Globals.tutarrow_pos != Vector2(0, 42)
	if visible:
		position = Globals.tutarrow_pos
