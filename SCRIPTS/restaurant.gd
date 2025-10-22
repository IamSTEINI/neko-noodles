extends Node2D


func _on_interactable_interacted(_body: Variant) -> void:
	$INTERACTABLE.can_interact = false
	Npcmanager.save_all_npcs()
	Npcmanager.save_all_tables()
	ShelfSaver.save_shelves()
	MachineSaver.save_all_machines()
	Scenemanager.change_scene(self.get_parent(), "supermarket")
