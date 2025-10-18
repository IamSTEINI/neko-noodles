extends Control


func _process(_delta: float) -> void:
	$FPS.text = str(Engine.get_frames_per_second()) + " FPS"
	
	var scene = get_tree().current_scene
	if scene == null:
		return
	
	var player = scene.get_node_or_null("PLAYER")
	if player == null:
		$Carrying.text = ""
		return
	
	var slot = player.get_node_or_null("ItemSlot") as Node2D
	if slot and slot.get_child_count() > 0:
		var item = slot.get_child(0)
		if item.has_meta("type"):
			$Carrying.text = str(item.get_meta("type"))
		else:
			$Carrying.text = "Carrying: Unknown"
	else:
		$Carrying.text = "Carrying: Nothing"

func _on_clear_npcs_pressed() -> void:
	Npcmanager.delete_npcs()


func _on_restore_npcs_pressed() -> void:
	Npcmanager.restore_npc()


func _on_save_npcs_pressed() -> void:
	Npcmanager.save_all_npcs()


func _on_save_shelves_pressed() -> void:
	ShelfSaver.save_shelves()
