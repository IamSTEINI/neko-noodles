extends Node2D

func _on_interactable_interacted(body: Variant) -> void:
		if body.has_node("ItemSlot"):
			var backpack_slot = body.get_node("BackpackSlot")
			if body.get_node("ItemSlot").get_child_count() > 0 or backpack_slot.get_child_count() > 0:
				var has_unpaid_items = false
				if body.get_node("ItemSlot").get_child_count() > 0:
					if body.get_node("ItemSlot").get_child(0).has_meta("buy_price"):
						has_unpaid_items = true
				if Globals.bought_backpack:
					for item in backpack_slot.get_children():
						if item.has_meta("buy_price"):
							has_unpaid_items = true
							break
				if has_unpaid_items:
					# User didnt pay
					Globals.log("Player didn't pay")
				else:
					$"GLASS DOOR/INTERACTABLE".can_interact = false
					Scenemanager.change_scene(self, "Main")
					Globals.log("Player paid")
			else:
				$"GLASS DOOR/INTERACTABLE".can_interact = false
				Globals.log("Player hasn't bought anything")
				Scenemanager.change_scene(self, "Main")
