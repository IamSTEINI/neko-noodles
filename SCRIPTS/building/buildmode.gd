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
	"floor":{
		"path": Vector2i(0,0),	# HERE WE USE CORDS, IN FURNITURE OR ANY OTHER PLACABLE STUFF WE JUST USE THE SCENE PATH
		"type": 0,
		"price": 1
	}
}
@export var tiles: Dictionary[String, Vector2i] = {}
var press_time := 0.0
var pressed := false

@export var active_building: PackedScene = null
@export var active_tile: String = ""
@export var active_building_type: int = 0

var label = preload("res://scenes/label.tscn")

func add_cursor():
	cursor = cursor_scene.instantiate()
	get_tree().current_scene.add_child(cursor)

func place_ground_tile(grid: Vector2i, tile: String):
	var tilemap = (get_tree().current_scene.get_node("RESTAURANT").get_node("Restaurant-base") as TileMapLayer)
	if tile in tiles:
		tilemap.set_cell(grid, 0, tiles[tile])

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pressed = true
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
	Globals.log("BUILD MODE:"+str(Globals.buildMode))
	Globals.log("ACTIVE TILE:"+str(active_tile))
	Globals.log("ACTIVE BUILDING:"+str(active_building))

func _process(delta: float) -> void:
	if not Globals.buildMode or active_tile == "" and active_building == null:
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
	if selecting and build_space != null and build_space.has_method("can_place"):
		for marker in active_markers:
			if is_instance_valid(marker):
				marker.queue_free()
		active_markers.clear()
		selected_grids = get_selected_area()
		for grid in selected_grids:
			if active_building != null:
				if active_building_type == 0:
					place_ground_tile(grid, active_tile)
				else:
					var pm = active_building.instantiate()
					if pm.has_node("Sprite2D") and build_space.can_place(current_grid, active_building_type):
						var preview_marker = pm.get_node("Sprite2D").duplicate()
						preview_marker.visible = true
						preview_marker.global_position = Vector2(grid) * grid_size + Vector2(grid_size / 2, grid_size / 2)
						preview_marker.offset = Vector2.ZERO
						var text_label = label.instantiate()
						text_label.global_position = Vector2(grid) * grid_size + Vector2(0, -15)
						get_tree().current_scene.add_child(preview_marker)
						get_tree().current_scene.add_child(text_label)
						active_markers.append(preview_marker)
						active_markers.append(text_label)
				
	
	cursor.global_position = Vector2(current_grid) * grid_size
	cursor.can = build_space.can_place(current_grid, active_building_type)
	cursor.get_node("debug").text = "WorldPos: " + str(cursor.global_position) + \
		"\nSelecting: " + str(selecting) + \
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
	if build_space == null:
		return
	
	if active_building_type == 0:
		if build_space.can_place(grid, active_building_type):
			place_ground_tile(grid, active_tile)
	elif active_building != null and build_space.can_place(grid, active_building_type):
		var building = active_building.instantiate()
		building.global_position = Vector2(grid) * grid_size + Vector2(grid_size / 2, grid_size / 2)
		build_space.add_to_grid(grid, building, active_building_type)
		get_tree().current_scene.add_child(building)

func handle_selection(grids: Array[Vector2i]) -> void:
	var build_space = get_tree().current_scene.get_node_or_null("BuildSpace")
	if build_space == null:
		return
	for grid in grids:
		if active_building_type == 0:
			if build_space.can_place(grid, active_building_type):
				place_ground_tile(grid, active_tile)
		else:
			if active_building != null and build_space.can_place(grid, active_building_type):
				var building = active_building.instantiate()
				building.global_position = Vector2(grid) * grid_size + Vector2(grid_size / 2, grid_size / 2)
				build_space.add_to_grid(grid, building, active_building_type)
				get_tree().current_scene.add_child(building)
