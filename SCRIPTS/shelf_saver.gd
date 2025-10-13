extends Node

@export var shelves: Array = []
var shelves_states: Array = []

func clear_shelves():
	shelves.clear()


func get_shelf_by_name(name: String) -> Node:
	for shelf in shelves:
		if shelf.name == name:
			return shelf
	return null

func restore_shelves():
	for shelf_state in shelves_states:
		var shelf_name = shelf_state["shelf_name"]
		var shelf = get_shelf_by_name(shelf_name)
		if shelf == null:
			Globals.log("Shelf not found: %s" % shelf_name)
			continue
		Globals.log("Restoring shelf: %s" % shelf_name)
		var restored_inventory = []
		for item_data in shelf_state["shelf_items"]:
			var scene_path = item_data["scene"]
			if not ResourceLoader.exists(scene_path):
				push_error("Missing scene: %s" % scene_path)
				continue
				
			var item_scene = load(scene_path)
			var item = item_scene.instantiate()
			item.name = item_data.get("name", "Unknown")
			item.position = item_data.get("pos", Vector2.ZERO)
			item.rotation = item_data.get("rotation", 0)
			item.set_meta("type", item_data.get("type", "0"))
			
			if item.get_meta("type") == "dough":
				item.doughType = item_data.get("dough_type")
			if item.get_meta("type") == "RawNoodle":
				item.NoodleType= item_data.get("noodle_type")
			if item.get_meta("type") == "Noodle":
				item.NoodleType = item_data.get("noodle_type")
				item.Price = item_data.get("noodle_price")
				item.NoodleTopping = item_data.get("noodle_topping")
				item.chopsticks = item_data.get("noodle_chopsticks")
			
			for key in item_data.keys():
				if key not in ["scene", "name", "pos", "rotation"]:
					item.set(key, item_data[key])
					
			restored_inventory.append([item.name, item])
			
		var needed = restored_inventory.size()
		var grid = shelf.get_node("InventoryUi/GridContainer")
		
		while grid.get_child_count() > needed:
			var last_child = grid.get_child(grid.get_child_count() - 1)
			grid.remove_child(last_child)
			last_child.queue_free()
			
		while grid.get_child_count() < needed:
			var new_slot = shelf.slot.instantiate()
			new_slot.connect("clicked_slot", Callable(shelf, "_on_slot_clicked_slot"))
			grid.add_child(new_slot)
			
		for i in range(needed):
			var entry = restored_inventory[i]
			var item_node = entry[1] as Node2D
			item_node.scale = Vector2(0.75, 0.75)
			item_node.position = Vector2(12.5, 12.5)
			if item_node.get_meta("type") == "Noodle":
				item_node.scale = Vector2(3, 3)
			elif item_node.get_meta("type") == "RawNoodle":
				item_node.scale = Vector2(0.5, 0.5)
				item_node.position = Vector2(12.5, 15)
			var target_slot = grid.get_child(i)
			target_slot.add_child(item_node)
			Globals.log("Restored item '%s' in shelf '%s', slot %d" % [item_node.name, shelf_name, i])
		shelf.inventory = restored_inventory
		shelf.update()

func save_shelves():
	shelves_states.clear()
	if shelves.size() == 0 || get_tree().current_scene.name != "Main":
		return
	for shelf in shelves:
		Globals.log("== Saving shelf " + str(shelf.name))
		var items = []
		for slot in shelf.get_node("InventoryUi/GridContainer").get_children():
			if slot.get_child_count() > 0:
				var item = slot.get_child(0)
				var data = {}
				if item.scene_file_path != "":
					data["scene"] = item.scene_file_path
				else:
					data["scene"] = item.get_script().resource_path
				
				data["name"] = item.name
				data["pos"] = item.position
				data["scale"] = item.scale
				data["type"] = item.get_meta("type")
				if item.get_meta("type") == "dough":
					data["dough_type"] = item.doughType
				if item.get_meta("type") == "RawNoodle":
					data["noodle_type"] = item.NoodleType
				if item.get_meta("type") == "Noodle":
					data["noodle_type"] = item.NoodleType
					data["noodle_price"] = item.Price
					data["noodle_topping"] = item.NoodleTopping
					data["noodle_chopsticks"] = item.chopsticks
				items.append(data)
		var state = {
			"shelf_name": shelf.name,
			"shelf_items": items
		}
		shelves_states.append(state)

	Globals.log("Shelves saved successfully")
	Globals.log(str(shelves_states))
