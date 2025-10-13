extends Node2D


func _on_interactable_interacted(_body: Variant) -> void:
	#	TODO JUST SAVING FOR NOW
	Npcmanager.save_all_npcs()
	Npcmanager.save_all_tables()
	ShelfSaver.save_shelves()
	Scenemanager.change_scene(self.get_parent(), "supermarket")
