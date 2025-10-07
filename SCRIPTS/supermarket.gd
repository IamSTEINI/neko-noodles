extends Node2D


func _on_interactable_interacted(body: Variant) -> void:
	Scenemanager.change_scene(get_tree().root, "Main")
