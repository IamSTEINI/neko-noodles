extends TextureButton

func _ready() -> void:
	$Tab.visible = false

func _on_button_down() -> void:
	for child in self.get_parent().get_children():
		if child.name != self.name:
			child.get_child(0).visible = false
	$Tab.visible = !$Tab.visible
	$Tab/TextureRect/Title.text = "EXPENSES DAY "+str(Globals.day)
