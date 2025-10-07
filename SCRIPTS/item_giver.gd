extends Node2D

@export var item: Node2D

func _ready() -> void:
	item.reparent(self)
	item.global_position = self.global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		item.reparent(body.get_node("ItemSlot"))
		item.global_position = body.get_node("ItemSlot").global_position
