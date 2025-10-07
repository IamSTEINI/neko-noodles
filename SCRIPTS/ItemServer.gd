extends Area2D

@export var tableClaimed = false

func _on_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		body.PICKUP = false
		var slot = body.get_node("ItemSlot")
		if slot.get_child_count() > 0:
			var noodle = slot.get_child(0)
			if noodle.get_meta("type") == "Noodle":
				if self.get_node("ItemSlot").get_child_count() > 0:
					Globals.log("SERVING NOT POSSIBLE: SLOT IS FULL")
				else:
					Globals.log("SERVING TO TABLE: " + noodle.name)
					slot.remove_child(slot.get_node("NoodleItem"))
					self.get_node("ItemSlot").add_child(noodle)
			else:
				Globals.log("SLOT HAS ANYTHING BUT AN ITEM")
		else:
			Globals.log("SLOT IS EMPTY")
