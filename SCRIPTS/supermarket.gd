extends Node2D


func _on_interactable_interacted(body: Variant) -> void:
		if body.has_node("ItemSlot"):
			if body.get_node("ItemSlot").get_child_count() > 0 or body.get_node("BackpackSlot").get_child_count() > 0:
				var price = body.get_node("ItemSlot").get_child(0).get_meta("buy_price")
				if Globals.bought_backpack:
					for item in body.get_node("BackpackSlot").get_children():
						if item.get_meta("buy_price") != null:
							return
				if price == null:
					$"GLASS DOOR/INTERACTABLE".can_interact = false
					Scenemanager.change_scene(self, "Main")
					Globals.log("Player paid")
				else:
					# User didnt pay
					Globals.log("Player didn't pay")
			else:
				$"GLASS DOOR/INTERACTABLE".can_interact = false
				Globals.log("Player hasn't bought anything")
				Scenemanager.change_scene(self, "Main")
