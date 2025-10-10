extends Node2D

@export var order_object: PackedScene

func add_order(noodle_name: String, noodle_type: int, npc_max_wait_time: float) -> int:
	if order_object == null:
		push_error("Order scene is not assigned!")
		return 0
	var new_order = order_object.instantiate()
	new_order.noodle_type = noodle_type
	new_order.noodle_name = noodle_name
	new_order.npc_m_w_t = npc_max_wait_time
	$CanvasLayer/Control/GridContainer.add_child(new_order)
	return $CanvasLayer/Control/GridContainer.get_child_count() - 1
	
func rem_order(order_id: int):
	if $CanvasLayer/Control/GridContainer.get_child(order_id):
		$CanvasLayer/Control/GridContainer.get_child(order_id).queue_free()
