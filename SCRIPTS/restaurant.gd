extends Node2D


func _on_interactable_interacted(_body: Variant) -> void:
	Scenemanager.change_scene(self.get_parent(), "supermarket")
