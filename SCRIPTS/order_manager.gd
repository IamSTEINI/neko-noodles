extends Node2D

var _order_id_counter: int = 0
@export var order_object: PackedScene

func add_order(noodle_name: String, noodle_type: int, noodle_topping:int, npc_max_wait_time: float) -> int:
	if order_object == null:
		push_error("Order scene is not assigned!")
		return -1

	_order_id_counter += 1
	var order_id = _order_id_counter

	var new_order = order_object.instantiate()
	new_order.noodle_type = noodle_type
	new_order.topping_type = noodle_topping
	new_order.noodle_name = noodle_name
	new_order.npc_m_w_t = npc_max_wait_time
	new_order.set_meta("id", order_id)

	$CanvasLayer/Control/GridContainer.add_child(new_order)
	return order_id


func rem_order(order_id: int):
	for child in $CanvasLayer/Control/GridContainer.get_children():
		if child.has_meta("id") and child.get_meta("id") == order_id:
			Globals.log("Removed order: " + str(order_id))
			child.queue_free()
			return
	push_warning("Order with ID " + str(order_id) + " not found")
