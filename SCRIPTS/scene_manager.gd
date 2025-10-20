extends CanvasLayer
var last_scene_name: String
var scene_path = "res://scenes/"
var transfer_item: Node2D = null
var trans_backpack: Array[Node2D] = []
@onready var animation: AnimationPlayer = $Transition

func _ready():
	hide()
	
func change_scene(from, to_scene: String) -> void:
	show()
	ShelfSaver.clear_shelves()
	last_scene_name = from.name
	animation.play("TRANSITION")
	Globals.log(from.name)
	
	if from.get_node("PLAYER"):
		Globals.log("Playerobj found, saving items")
		var player = from.get_node("PLAYER")
		if player.get_node("ItemSlot"):
			var slot = player.get_node("ItemSlot") as Node2D
			if slot.get_child_count() > 0:
				var item = slot.get_child(0)
				slot.remove_child(item)
				transfer_item = item
				add_child(transfer_item)
				transfer_item.hide()
				Globals.log("Saved ItemSlot: " + str(transfer_item.name))
		
		if player.get_node("BackpackSlot"):
			var backpack_slot = player.get_node("BackpackSlot") as Node2D
			Globals.log("Found BackpackSlot with " + str(backpack_slot.get_child_count()) + " items")
			trans_backpack.clear()
			for item in backpack_slot.get_children():
				backpack_slot.remove_child(item)
				trans_backpack.append(item)
				add_child(item)
				item.hide()
				Globals.log("Saved BackpackSlot item: " + str(item.name))
			
			Globals.log("Total backpack items saved: " + str(trans_backpack.size()))
	
	var path = scene_path + to_scene + ".tscn"
	await animation.animation_finished
	get_tree().change_scene_to_file(path)
	await get_tree().tree_changed
	await get_tree().process_frame
	
	if to_scene == "Main":
		Npcmanager.restore_npc()
		Npcmanager.restore_table_states()
		ShelfSaver.restore_shelves()
	
	animation.play_backwards("TRANSITION")
	if transfer_item != null or trans_backpack.size() > 0:
		call_deferred("_restore_items")

func _restore_items() -> void:
	var new_scene = get_tree().current_scene
	if new_scene:
		Globals.log("Now in: " + new_scene.name)
		if new_scene.get_node("PLAYER"):
			Globals.log("Playerobj found, restoring items")
			var player = new_scene.get_node("PLAYER")
			
			if transfer_item !=null and player.get_node("ItemSlot"):
				var slot = player.get_node("ItemSlot") as Node2D
				if slot.get_child_count() == 0:
					remove_child(transfer_item)
					slot.add_child(transfer_item)
					transfer_item.position = Vector2.ZERO
					transfer_item.show()
					Globals.log("Restored ItemSlot item: " + str(transfer_item.name))
					transfer_item = null
			
			if trans_backpack.size()>0 and player.get_node("BackpackSlot"):
				var backpack_slot = player.get_node("BackpackSlot") as Node2D
				Globals.log("Restoring " + str(trans_backpack.size()) + " backpack items")
				for item in trans_backpack:
					remove_child(item)
					backpack_slot.add_child(item)
					item.position = Vector2.ZERO
					item.hide()
					Globals.log("Restorred BackpackSlot item: " + str(item.name))
				
				trans_backpack.clear()
				await get_tree().process_frame
				if player.has_method("_initialize_backpack"):
					player._initialize_backpack()
				else:
					Globals.refresh_inv = true
