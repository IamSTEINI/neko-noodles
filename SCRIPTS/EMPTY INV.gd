extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var item_slot = body.get_node("ItemSlot")
	body.PICKUP = false
	for child in item_slot.get_children():
		child.queue_free()
