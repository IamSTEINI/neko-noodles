extends Node2D

var grid_size = Buildmode.grid_size
var grid_data = {}

enum BuildingType {
	GROUND,
	WALL,
	FURNITURE,
	DECORATION
}

class GridTile:
	var node: Node
	var type: BuildingType
	var grid_pos: Vector2i
	
	func _init(n: Node, t: BuildingType, pos: Vector2i):
		node = n
		type = t
		grid_pos = pos

func _ready():
	if TileSaver.has_saved_data():
		#Globals.log("Found saved data in tiles")
		await get_tree().process_frame
	else:
		Globals.log("No saved data")
		load_existing_tilemap()

func load_existing_tilemap():
	var tilemap = get_tree().current_scene.get_node_or_null("RESTAURANT")
	if tilemap == null:
		return
	var base_layer = tilemap.get_node_or_null("Restaurant-base") as TileMapLayer
	if base_layer == null:
		return
	
	var used_cells = base_layer.get_used_cells()
	for cell_pos in used_cells:
		var atlas_coords = base_layer.get_cell_atlas_coords(cell_pos)
		var tile_type = get_type_from_atlas_coords(atlas_coords)
		
		grid_data[cell_pos] = GridTile.new(null, tile_type, cell_pos)
	
	Globals.log("Loaded " + str(grid_data.size()) + " tiles from tilemap")

func get_type_from_atlas_coords(coords: Vector2i) -> BuildingType:
	for key in Buildmode.building_parts:
		var part = Buildmode.building_parts[key]
		if part["type"] == 0 or part["type"] == 1:
			if part["path"] == coords:
				return part["type"] as BuildingType
	
	return BuildingType.GROUND

func update_tile_from_tilemap(pos: Vector2i, tile_type: int):
	$PlaceSound.play()
	grid_data[pos] = GridTile.new(null, tile_type as BuildingType, pos)
	Globals.log("Updated grid at " + str(pos) + " to type " + str(tile_type))

func grid_occupied(pos: Vector2i) -> bool:
	return grid_data.has(pos)

func get_tile(pos: Vector2i) -> GridTile:
	if grid_data.has(pos):
		return grid_data[pos]
	return null

func get_tile_type(pos: Vector2i) -> int:
	var tile = get_tile(pos)
	if tile != null:
		return tile.type
	return -1

func is_ground(pos: Vector2i) -> bool:
	return get_tile_type(pos) == BuildingType.GROUND

func can_place(pos: Vector2i, building_type: BuildingType) -> bool:
	var world_pos = Vector2(pos) * grid_size
	
	if world_pos.x < -200 or world_pos.x > 2500:
		return false
	if world_pos.y < 0 or world_pos.y > 1700:
		return false
	
	match building_type:
		BuildingType.GROUND:
			return not grid_occupied(pos)
		BuildingType.WALL:
			return is_ground(pos)
		BuildingType.FURNITURE:
			if not grid_occupied(pos):
				return false
			var tile = get_tile(pos)
			return tile.type == BuildingType.GROUND
		BuildingType.DECORATION:
			if not grid_occupied(pos):
				return false
			var tile = get_tile(pos)
			return tile.type == BuildingType.WALL
	
	return false

func add_to_grid(pos: Vector2i, node: Node, building_type: BuildingType):
	var tile = GridTile.new(node, building_type, pos)
	grid_data[pos] = tile
	var navreg =  (self.get_parent().get_node("NavigationRegion2D") as NavigationRegion2D)
	navreg.enabled = false
	$PlaceSound.play()
	navreg.enabled = true # RELOADING
	#Globals.log(str(grid_data.size()) + " tiles in grid")

func remove_from_grid(pos: Vector2i):
	$PlaceSound.play()
	if grid_data.has(pos):
		var tile = grid_data[pos]
		if is_instance_valid(tile.node):
			tile.node.queue_free()
		grid_data.erase(pos)
