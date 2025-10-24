extends Node2D

var grid_size = Buildmode.grid_size
var grid_data = {}

enum BuildingType {
	GROUND,
	WALL,
	FURNITURE
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
		if not grid_data.has(cell_pos):
			grid_data[cell_pos] = GridTile.new(null, BuildingType.GROUND, cell_pos)
	
	Globals.log("got " + str(grid_data.size()) + " tils from tilemap")
	
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
	if grid_occupied(pos):
		return false
	
	var world_pos = Vector2(pos) * grid_size
	if world_pos.x < -100 or world_pos.x > 2300:
		return false
	if world_pos.y < 200 or world_pos.y > 1900:
		return false
	
	match building_type:
		BuildingType.GROUND:
			return true
		BuildingType.WALL:
			return is_ground(pos)
		BuildingType.FURNITURE:
			return is_ground(pos)
	
	return false
func add_to_grid(pos: Vector2i, node: Node, building_type: BuildingType):
	var tile = GridTile.new(node, building_type, pos)
	grid_data[pos] = tile
	Globals.log(str(grid_data.size()) + " tiles placed")

func remove_from_grid(pos: Vector2i):
	if grid_data.has(pos):
		var tile = grid_data[pos]
		if is_instance_valid(tile.node):
			tile.node.queue_free()
		grid_data.erase(pos)
