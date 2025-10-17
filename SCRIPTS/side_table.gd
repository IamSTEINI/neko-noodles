extends Node2D


func _on_interactable_interacted(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		if body.get_node("ItemSlot").get_child_count() == 0:
			body.get_node("ItemSlot").get_child(0).reparent($slot)
			$slot.get_child(0).position = Vector2(0,0)
			$slot.get_child(0).global_position = $slot.global_position

func _on_interactable_player_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		if body.get_node("ItemSlot").get_child_count() > 0:
			$INTERACTABLE.can_interact = true
			if $slot.get_child_count() > 0:
				if $slot.get_child(0).get_meta("type") == "Noodle" or $slot.get_child(0).get_meta("type") == "Topping":
					$INTERACTABLE.text = "Add"
					$INTERACTABLE.can_interact = true
				else:
					$INTERACTABLE.can_interact = false
			else:
				if body.get_node("ItemSlot").get_child_count() > 0:
					if body.get_node("ItemSlot").get_child(0).get_meta("type") == "Noodle" or body.get_node("ItemSlot").get_child(0).get_meta("type") == "Topping":
						$INTERACTABLE.text = "Place"
						$INTERACTABLE.can_interact = true
					else:
						$INTERACTABLE.can_interact = false
				else:
					$INTERACTABLE.can_interact = false
		else:
			$INTERACTABLE.can_interact = false
