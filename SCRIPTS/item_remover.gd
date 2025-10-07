extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player" && body.has_node("ItemSlot"):
		for child in body.get_node("ItemSlot").get_children():
			child.queue_free()
