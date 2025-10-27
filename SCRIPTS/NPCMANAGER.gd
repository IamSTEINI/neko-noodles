extends Node
@export var npc_scene: PackedScene
@export var coin_scene: PackedScene

@export var Tables: Node = null
@export var Entry: Node = null
@export var SpawnRanges: Node = null

var npc_states = []
var table_states = []

func _ready():
	randomize()
	Globals.npc_spawn.connect(Callable(self, "spawn_npc"))
	
func _on_spawn_npc_pressed() -> void:
	spawn_npc()
	
func spawn_npc():
	var npc = npc_scene.instantiate()
	npc.Tables = Tables
	npc.Entry = Entry
	npc.coin_scene = coin_scene
	npc.SpawnRanges = SpawnRanges
	npc.set_meta("type", "NPC")
	get_tree().current_scene.add_child(npc)

func delete_npcs():
	for child in get_tree().root.get_node("Main").get_children():
		if child.has_meta("type") and child.get_meta("type") == "NPC":
			child.queue_free()

func save_all_npcs():
	npc_states = []
	for child in get_tree().root.get_node("Main").get_children():
		if child.has_meta("type") and child.get_meta("type") == "NPC":
			save_npc_state(child)
	Globals.log("Saved "+str(npc_states.size())+" NPCs")
	
func save_all_tables():
	table_states = []
	for child in get_tree().root.get_node("Main").get_node("TABLES").get_children():
		save_table_state(child)
	Globals.log("Saved " + str(table_states.size()) + " tables")

func restore_table_states() -> void:
	var tables_node = get_tree().root.get_node("Main/TABLES")
	for table in tables_node.get_children():
		for state in table_states:
			if state["name"] == table.name:
				table.capacity = state["capacity"]
				table.customers = state["customers"]
				table.update_capacity_text()
				Globals.log("Restored table: " + table.name + " (" + str(state["customers"]) + "/" + str(state["capacity"]) + ")")
				break

func save_table_state(table: Node2D):
	var state = {
		"name": table.name,
		"capacity": table.capacity,
		"customers": table.customers,
	}
	
	Globals.log(str(state))
	
	table_states.append(state)
	
func save_npc_state(npc: Node2D):
	Globals.log("== SAVED NPC #"+str(npc.name))
	var character_type = "BROWN_CAT" if npc.get_node("BROWN_CAT").visible else "WHITE_CAT"
	
	var state = {
		"position_x": npc.global_position.x,
		"position_y": npc.global_position.y,
		"spawn_x": npc.SPAWN_LOC.x if npc.SPAWN_LOC else npc.global_position.x,
		"spawn_y": npc.SPAWN_LOC.y if npc.SPAWN_LOC else npc.global_position.y,
		"reached_entry": npc.reached_entry,
		"reached_table": npc.reached_table,
		"got_order": npc.got_order,
		"leaving": npc.leaving,
		"generated_order": npc.generated_order,
		"order_id": npc.order_id,
		"wait_time": npc.wait_time,
		"npc_name": npc.name,
		"character_type": character_type,
		"tooltip": npc.get_meta("tooltip") if npc.has_meta("tooltip") else "",
		"description": npc.get_meta("description") if npc.has_meta("description") else "",
		"chosen_table_name": npc.chosen_table.name if npc.chosen_table else null,
	}
	npc_states.append(state)
	Globals.log(str(state))
	
func restore_npc():
	for state in npc_states:
		var npc = npc_scene.instantiate()
		npc.Tables = Tables
		npc.Entry = Entry
		npc.coin_scene = coin_scene
		npc.SpawnRanges = SpawnRanges
		npc.set_meta("type", "NPC")
		npc.global_position = Vector2(state["position_x"], state["position_y"])
		npc.SPAWN_LOC = Vector2(state["spawn_x"], state["spawn_y"])
		npc.reached_entry = state["reached_entry"]
		npc.reached_table = state["reached_table"]
		npc.got_order = state["got_order"]
		npc.leaving = state["leaving"]
		npc.generated_order = state["generated_order"]
		npc.order_id = state["order_id"]
		npc.wait_time = state["wait_time"]
		npc.name = state["npc_name"]
		npc.set_meta("tooltip", state["tooltip"])
		npc.set_meta("description", state["description"])
		
		if state["character_type"] == "BROWN_CAT":
			npc.get_node("BROWN_CAT").show()
			npc.get_node("WHITE_CAT").hide()
			npc.chosen_character = npc.get_node("BROWN_CAT")
		else:
			npc.get_node("WHITE_CAT").show()
			npc.get_node("BROWN_CAT").hide()
			npc.chosen_character = npc.get_node("WHITE_CAT")
		npc.TextBox.hide()
		npc.is_speaking = false
		get_tree().current_scene.add_child(npc)
		npc.call_deferred("apply_restore", state)
		if state["chosen_table_name"]:
			npc.chosen_table = get_tree().current_scene.get_node("TABLES").get_node_or_null(NodePath(state["chosen_table_name"]))
			if npc.chosen_table:
				npc.food_slot = npc.find_empty_slot(npc.chosen_table.food_slots)
				if npc.reached_table:
					if not npc.got_order:
						npc.get_node("Order").show()
						npc.get_node("Order/OrderNoodle").NoodleType = npc.generated_order[0]
						npc.get_node("Order/OrderNoodle").NoodleTopping = npc.generated_order[1]
				else:
					npc.set_target_position(npc.chosen_table.global_position)

		if npc.reached_table:
			npc.chosen_character.play("IDLE_UP")
		else:
			if npc.chosen_table:
				npc.set_target_position(npc.chosen_table.global_position)
			elif npc.Entry:
				npc.set_target_position(npc.Entry.global_position)
				
		Globals.log("Restored NPC #"+state["npc_name"])

func clear():
	npc_states.clear()
	table_states.clear()
