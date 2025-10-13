extends Control


func _on_clear_npcs_pressed() -> void:
	Npcmanager.delete_npcs()


func _on_restore_npcs_pressed() -> void:
	Npcmanager.restore_npc()


func _on_save_npcs_pressed() -> void:
	Npcmanager.save_all_npcs()


func _on_save_shelves_pressed() -> void:
	ShelfSaver.save_shelves()
