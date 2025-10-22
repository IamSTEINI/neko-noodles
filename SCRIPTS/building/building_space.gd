extends Node2D

var grid_size = Buildmode.grid_size
var grid_data = {}

func grid_occupied(pos: Vector2i) -> bool:
	return grid_data.has(pos)

func can_place(pos: Vector2i) -> bool:
	if grid_occupied(pos):
		return false
	
	var world_pos = Vector2(pos) * grid_size
	if world_pos.x < -200 or world_pos.x > 2300:
		return false
	if world_pos.y < 0 or world_pos.y > 1900:
		return false
	
	return true

func add_to_grid(pos: Vector2i, node: Node):
	grid_data[pos] = node
	Globals.log(str(grid_data))
