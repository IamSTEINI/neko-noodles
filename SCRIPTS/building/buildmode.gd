extends Node2D

var grid_size = 100
var current_grid: Vector2i
var cursor_scene = preload("res://scenes/cursor.tscn")
var cursor: Node2D
var selecting := false
var start_grid: Vector2i
var selected_grids: Array[Vector2i] = []
var active_markers: Array[Node] = []

@export var building_parts: Dictionary[String, Dictionary] = {
	"table": {
		"path": preload("res://scenes/Table.tscn"),
		"type": 2,
		"price": 2,
		"name": "Table"
	},
	"lamp": {
		"path": preload("res://scenes/buildings/lamp.tscn"),
		"type": 2,
		"price": 5,
		"name": "Lamp"
	},
	"floor": {
		"path": Vector2i(0, 0),
		"type": 0,
		"price": 1,
		"name": "FLOOR"
	},
	"wall-l": {
		"path": Vector2i(0, 1),
		"type": 1,
		"price": 2,
		"name": "LEFT WALL"
	},
	"wall-r": {
		"path": Vector2i(1, 0),
		"type": 1,
		"price": 2,
		"name": "RIGHT WALL"
	},
	"wall-b": {
		"path": Vector2i(1, 1),
		"type": 1,
		"price": 2,
		"name": "BOTTOM WALL"
	},
	"wall-t": {
		"path": Vector2i(1, 3),
		"type": 1,
		"price": 2,
		"name": "TOP WALL"
	},
	"wall-tt": {
		"path": Vector2i(1, 2),
		"type": 1,
		"price": 2,
		"name": "TOP WALL"
	},
	"corner-wall-r": {
		"path": Vector2i(2, 1),
		"type": 1,
		"price": 2,
		"name": "RIGHT CORNER"
	},
	"corner-wall-l": {
		"path": Vector2i(3, 1),
		"type": 1,
		"price": 2,
		"name": "LEFT CORNER"
	},
	"corner-small-l": {
		"path": Vector2i(3, 0),
		"type": 1,
		"price": 2,
		"name": "SMALL CORNER"
	},
	"corner-small-r": {
		"path": Vector2i(2, 0),
		"type": 1,
		"price": 2,
		"name": "SMALL CORNER"
	},
	"corner-t-r": {
		"path": Vector2i(2, 3),
		"type": 1,
		"price": 2,
		"name": "WALL CORNER"
	},
	"corner-t-l": {
		"path": Vector2i(0, 3),
		"type": 1,
		"price": 2,
		"name": "WALL CORNER"
	},
	"corner-tt-r": {
		"path": Vector2i(2, 2),
		"type": 1,
		"price": 2,
		"name": "WALL CORNER"
	},
	"corner-tt-l": {
		"path": Vector2i(0, 2),
		"type": 1,
		"price": 2,
		"name": "WALL CORNER"
	}
}

var press_time := 0.0
var pressed := false
var is_deleting := false

@export var active_tile: String = ""
@export var active_building_type: int = 0

var label = preload("res://scenes/label.tscn")

func add_cursor():
	cursor = cursor_scene.instantiate()
	get_tree().current_scene.add_child(cursor)

func place_ground_tile(grid: Vector2i, tile_name: String):
	if not tile_name in building_parts:
		return
	
	var tile_data = building_parts[tile_name]
	if tile_data["type"] != 0 and tile_data["type"] != 1:
		return
	
	var tilemap = (get_tree().current_scene.get_node("RESTAURANT").get_node("Restaurant-base") as TileMapLayer)
	var atlas_coords: Vector2i = tile_data["path"]
	tilemap.set_cell(grid, 0, atlas_coords)

func delete_tile(grid: Vector2i):
	var build_space = get_tree().current_scene.get_node_or_null("BuildSpace")
	if build_space == null:
		return
	
	var tile = build_space.get_tile(grid)
	if tile == null:
		return
	
	if tile.type == 2:
		build_space.remove_from_grid(grid)
	elif tile.type == 1:
		var tilemap = (get_tree().current_scene.get_node("RESTAURANT").get_node("Restaurant-base") as TileMapLayer)
		var ground_coords = Vector2i(0, 0)
		for key in building_parts:
			if building_parts[key]["type"] == 0:
				ground_coords = building_parts[key]["path"]
				break
		tilemap.set_cell(grid, 0, ground_coords)
		build_space.update_tile_from_tilemap(grid, 0)
	elif tile.type == 0:
		var tilemap = (get_tree().current_scene.get_node("RESTAURANT").get_node("Restaurant-base") as TileMapLayer)
		tilemap.erase_cell(grid)
		build_space.remove_from_grid(grid)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pressed = true
				is_deleting = false
				press_time = 0.0
				selecting = true
				start_grid = current_grid
				selected_grids.clear()
			else:
				pressed = false
				selecting = false
				
				if press_time < 0.15:
					handle_click(current_grid)
				else:
					handle_selection(selected_grids)
				for marker in active_markers:
					if is_instance_valid(marker):
						marker.queue_free()
				selected_grids.clear()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				pressed = true
				is_deleting = true
				press_time = 0.0
				selecting = true
				start_grid = current_grid
				selected_grids.clear()
			else:
				pressed = false
				selecting = false
				
				if press_time < 0.15:
					handle_delete_click(current_grid)
				else:
					handle_delete_selection(selected_grids)
				for marker in active_markers:
					if is_instance_valid(marker):
						marker.queue_free()
				selected_grids.clear()

func get_selected_area() -> Array[Vector2i]:
	if not selecting:
		return []
	var grids: Array[Vector2i] = []
	var min_x = min(start_grid.x, current_grid.x)
	var max_x = max(start_grid.x, current_grid.x)
	var min_y = min(start_grid.y, current_grid.y)
	var max_y = max(start_grid.y, current_grid.y)
	
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			grids.append(Vector2i(x, y))
		
	return grids

func _ready() -> void:
	Globals.log("BUILD MODE:" + str(Globals.buildMode))
	Globals.log("ACTIVE TILE:" + str(active_tile))

func _process(delta: float) -> void:
	if not Globals.buildMode:
		return
		
	if cursor == null or not is_instance_valid(cursor):
		return
	
	if pressed:
		press_time += delta
	
	var mouse = get_global_mouse_position()
	current_grid = Vector2i(floor(mouse.x / grid_size), floor(mouse.y / grid_size))
	
	if !get_tree().current_scene:
		return
	
	var build_space = get_tree().current_scene.get_node_or_null("BuildSpace")
	if build_space == null:
		return
	
	if selecting:
		selected_grids = get_selected_area()
		
		if not is_deleting and active_tile != "" and build_space.has_method("can_place"):
			for marker in active_markers:
				if is_instance_valid(marker):
					marker.queue_free()
			active_markers.clear()
			
			for grid in selected_grids:
				var building_data = building_parts[active_tile]
				if active_building_type == 0:
					continue
				elif active_building_type == 1:
					pass
				elif active_building_type == 2:
					if active_tile in building_parts:
						if building_data["path"] is PackedScene:
							var pm = (building_data["path"] as PackedScene).instantiate()
							if pm.has_node("Sprite2D") and build_space.can_place(grid, active_building_type):
								var preview_marker = pm.get_node("Sprite2D").duplicate()
								preview_marker.visible = true
								preview_marker.global_position = Vector2(grid) * grid_size + Vector2(grid_size / 2, grid_size / 2)
								preview_marker.offset = Vector2.ZERO
								
								get_tree().current_scene.add_child(preview_marker)
								active_markers.append(preview_marker)
							pm.queue_free()
				var text_label = label.instantiate()
				text_label.text = "-"+str(building_data["price"])
				text_label.global_position = Vector2(grid) * grid_size + Vector2(0, -15)
				get_tree().current_scene.add_child(text_label)
				active_markers.append(text_label)
		
		elif is_deleting:
			for marker in active_markers:
				if is_instance_valid(marker):
					marker.queue_free()
			active_markers.clear()
	
	cursor.global_position = Vector2(current_grid) * grid_size
	
	if is_deleting:
		cursor.can = build_space.grid_occupied(current_grid)
	else:
		cursor.can = active_tile != "" and build_space.can_place(current_grid, active_building_type)
	
	cursor.get_node("debug").text = "WorldPos: " + str(cursor.global_position) + \
		"\nSelecting: " + str(selecting) + \
		"\nMode: " + ("DELETE" if is_deleting else "BUILD") + \
		"\nCAN PLACE? " + str(cursor.can) + \
		"\nType: " + get_type_name(active_building_type) + \
		"\nGrids Selected: " + str(selected_grids.size())

func get_type_name(type: int) -> String:
	match type:
		0: return "GROUND"
		1: return "WALL"
		2: return "FURNITURE"
		_: return "UNKNOWN"

func handle_click(grid: Vector2i) -> void:
	var build_space = get_tree().current_scene.get_node_or_null("BuildSpace")
	if build_space == null or not active_tile in building_parts:
		return
	
	if not build_space.can_place(grid, active_building_type):
		return
	
	var building_data = building_parts[active_tile]
	
	if building_data["price"] > Globals.money:
		#Globals.log("Player has not enough money")
		return
	if active_building_type == 0 or active_building_type == 1:
		place_ground_tile(grid, active_tile)
		build_space.update_tile_from_tilemap(grid, active_building_type)
	elif active_building_type == 2:
		if building_data["path"] is PackedScene:
			var building = (building_data["path"] as PackedScene).instantiate()
			building.global_position = Vector2(grid) * grid_size + Vector2(grid_size / 2, grid_size / 2)
			if building_data["name"] == "Table":
				var tables_node = get_tree().current_scene.get_node_or_null("TABLES")
				if tables_node != null:
					building.name = "Table"
					building.capacity = 1
					tables_node.add_child(building)
				else:
					get_tree().current_scene.get_node_or_null("FURNITURE").add_child(building)
			else:	
				get_tree().current_scene.get_node_or_null("FURNITURE").add_child(building)
			build_space.add_to_grid(grid, building, active_building_type)
	pay_building(building_data["price"])

func pay_building(price: int) -> void:
	Expenses.add_transaction("Building", price)
	Globals.money -= price
	pass

func handle_selection(grids: Array[Vector2i]) -> void:
	var build_space = get_tree().current_scene.get_node_or_null("BuildSpace")
	if build_space == null or not active_tile in building_parts:
		return
	for grid in grids:
		if not build_space.can_place(grid, active_building_type):
			continue
		var building_data = building_parts[active_tile]
		if building_data["price"] > Globals.money:
			#Globals.log("Player has not enough money")
			return
		if active_building_type == 0 or active_building_type == 1:
			place_ground_tile(grid, active_tile)
			build_space.update_tile_from_tilemap(grid, active_building_type)
		elif active_building_type == 2:
			if building_data["path"] is PackedScene:
				var building = (building_data["path"] as PackedScene).instantiate()
				building.global_position = Vector2(grid) * grid_size + Vector2(grid_size / 2, grid_size / 2)
				if building_data["name"] == "Table":
					var tables_node = get_tree().current_scene.get_node_or_null("TABLES")
					if tables_node != null:
						building.name = "Table"
						building.capacity = 1
						tables_node.add_child(building)
					else:
						get_tree().current_scene.get_node_or_null("FURNITURE").add_child(building)
				else:	
					get_tree().current_scene.get_node_or_null("FURNITURE").add_child(building)
				build_space.add_to_grid(grid, building, active_building_type)
		pay_building(building_data["price"])

func handle_delete_click(grid: Vector2i) -> void:
	delete_tile(grid)

func handle_delete_selection(grids: Array[Vector2i]) -> void:
	for grid in grids:
		delete_tile(grid)
