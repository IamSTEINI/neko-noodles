extends Node2D

@export var item: Node2D
@export var respawn_time: float = 5.0
@export var text: String = "Item Giver"

func _ready() -> void:
	$RichTextLabel.text = text
	if item.get_parent() != self:
		item.reparent(self)
	item.global_position = self.global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player" and item != null and body.has_node("ItemSlot"):
		var item_slot = body.get_node("ItemSlot")

		if item_slot.get_child_count() == 0:
			var item_clone = item.duplicate()
			get_tree().current_scene.add_child(item_clone)
			item_clone.reparent(item_slot)
			item_clone.position = Vector2.ZERO
			item_clone.show()
			item.visible = false
			item.process_mode = Node.PROCESS_MODE_DISABLED
			respawn_item()
		else:
			Globals.log("Player's Itemslot is full")


func respawn_item() -> void:
	var t := get_tree().create_timer(respawn_time)
	t.timeout.connect(func ():
		item.visible = true
		item.process_mode = Node.PROCESS_MODE_INHERIT
		item.global_position = self.global_position
	)
