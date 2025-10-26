extends Node

var saved_tilemap_cells: Dictionary = {}
var saved_furniture: Array[Dictionary] = []

func save_building_data(grid_data: Dictionary, tilemap: TileMapLayer):
	saved_tilemap_cells.clear()
	saved_furniture.clear()
	
	# ALWAYS CLEAR BEFORE SAVING.... :\\\\
	
	if tilemap != null:
		var used_cells = tilemap.get_used_cells()
		for cell_pos in used_cells:
			var atlas_coords = tilemap.get_cell_atlas_coords(cell_pos)
			saved_tilemap_cells[cell_pos] = atlas_coords
		
	var furniture_count = 0
	for grid_pos in grid_data:
		var tile = grid_data[grid_pos]
		if tile.type == 2 and is_instance_valid(tile.node):
			furniture_count += 1
	
	for grid_pos in grid_data:
		var tile = grid_data[grid_pos]
		if tile.type == 2 and is_instance_valid(tile.node):
			var furniture_data = {
				"grid_pos": grid_pos,
				"position": tile.node.global_position,
				"type": tile.type,
				"node_name": tile.node.name,
				"properties": {}
			}
			
			var found_key = false
			for key in Buildmode.building_parts:
				var part = Buildmode.building_parts[key]
				if part["type"] == 2 and part["path"] is PackedScene:
					var node_scene = tile.node.scene_file_path
					var part_scene = (part["path"] as PackedScene).resource_path
					
					if node_scene == part_scene:
						furniture_data["building_key"] = key
						furniture_data["scene_name"] = part["name"]
						found_key = true
						break
			
			var is_table = furniture_data.get("scene_name", "") == "Table"
			if is_table:
				if "capacity" in tile.node:
					furniture_data["properties"]["capacity"] = tile.node.get("capacity")
				else:
					furniture_data["properties"]["capacity"] = 1
			
			saved_furniture.append(furniture_data)
	
	Globals.log("Total: " + str(saved_furniture.size()))

func restore_building_data(build_space: Node2D, tilemap: TileMapLayer, tables_node: Node):
	if build_space == null or tilemap == null:
		Globals.log("Tm or bs empty")
		return
	
	for grid_pos in build_space.grid_data.keys():
		var tile = build_space.grid_data[grid_pos]
		if tile.type == 2 and is_instance_valid(tile.node):
			tile.node.queue_free()
	
	build_space.grid_data.clear()
	
	tilemap.clear()
	for cell_pos in saved_tilemap_cells:
		var atlas_coords = saved_tilemap_cells[cell_pos]
		tilemap.set_cell(cell_pos, 0, atlas_coords)
		var tile_type = build_space.get_type_from_atlas_coords(atlas_coords)
		build_space.grid_data[cell_pos] = build_space.GridTile.new(null, tile_type, cell_pos)
	
	Globals.log("Restored " + str(saved_tilemap_cells.size()) + " tilemaps")
	
	for furniture_data in saved_furniture:
		var building_key = furniture_data.get("building_key", "") # Thanks godot
		if building_key == "" or not building_key in Buildmode.building_parts:
			continue
		
		var building_part = Buildmode.building_parts[building_key]
		if not building_part["path"] is PackedScene:
			continue
		
		var furniture = (building_part["path"] as PackedScene).instantiate()
		furniture.global_position = furniture_data["position"]
		
		if furniture_data.has("node_name"):
			furniture.name = furniture_data["node_name"]
		
		var props = furniture_data.get("properties", {})
		if "capacity" in props:
			furniture.set("capacity", props["capacity"])
		
		var scene_name = furniture_data.get("scene_name", "")
		
		if scene_name == "Table" and tables_node != null:
			tables_node.add_child(furniture)
			Globals.log(str(building_part))
			if furniture.has_method("update_capacity_text"):
				furniture.update_capacity_text()
		else:
			build_space.get_tree().current_scene.add_child(furniture)
		
		var grid_pos = furniture_data["grid_pos"]
		build_space.grid_data[grid_pos] = build_space.GridTile.new(
			furniture, 
			furniture_data["type"], 
			grid_pos
		)
	
	Globals.log("Restored " + str(saved_furniture.size()) + " furnitures")

func has_saved_data() -> bool:
	return saved_tilemap_cells.size() > 0 or saved_furniture.size() > 0

func clear_saved_data():
	saved_tilemap_cells.clear()
	saved_furniture.clear()
