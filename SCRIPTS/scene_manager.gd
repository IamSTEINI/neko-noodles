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
	Globals.buildMode = false
	animation.play("TRANSITION")
	Globals.log(from.name)
	
	if from.name == "Main":
		save_building_data_from_scene(from)
	
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
		restore_building_data_to_scene()
		Npcmanager.restore_npc()
		Npcmanager.restore_table_states()
		ShelfSaver.restore_shelves()
		Buildmode.add_cursor()
	
	animation.play_backwards("TRANSITION")
	if transfer_item != null or trans_backpack.size() > 0:
		call_deferred("_restore_items")

func save_building_data_from_scene(scene: Node):
	var build_space = scene.get_node_or_null("BuildSpace")
	var restaurant = scene.get_node_or_null("RESTAURANT")
	
	if build_space == null or restaurant == null:
		Globals.log("BuildSpace or RESTAURANT not found, skipping building save")
		return
	
	var tilemap = restaurant.get_node_or_null("Restaurant-base") as TileMapLayer
	if tilemap == null:
		Globals.log("TileMap not found!")
		return
	
	TileSaver.save_building_data(build_space.grid_data, tilemap)


func restore_building_data_to_scene():
	if not TileSaver.has_saved_data():
		Globals.log("No saved building data")
		return
	
	var scene = get_tree().current_scene
	var build_space = scene.get_node_or_null("BuildSpace")
	var restaurant = scene.get_node_or_null("RESTAURANT")
	
	if build_space == null or restaurant == null:
		Globals.log("BuildSpace or RESTAURANT not found, skipping building restore")
		return
	
	var tilemap = restaurant.get_node_or_null("Restaurant-base") as TileMapLayer
	var tables_node = scene.get_node_or_null("TABLES")
	
	if tilemap == null:
		Globals.log("TileMap not found!")
		return
	
	TileSaver.restore_building_data(build_space, tilemap, tables_node)

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
