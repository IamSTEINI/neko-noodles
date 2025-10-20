extends TextureButton
signal slot_clicked(index: int)

var index := -1

func _ready() -> void:
	if not self.pressed.is_connected(_on_pressed):
		self.pressed.connect(_on_pressed)
	
func _on_pressed() -> void:
	Globals.log("PRESSED SLOT")
	emit_signal("slot_clicked", index)
	
func _pressed():
	Globals.log("PRESSED SLOT")
	emit_signal("slot_clicked", index)
