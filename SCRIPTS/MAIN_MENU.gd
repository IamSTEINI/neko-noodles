extends Control


func _on_texture_button_pressed() -> void:
	Scenemanager.change_scene($".", "Main")
