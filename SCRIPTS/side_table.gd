extends Node2D

var NoodleScene: PackedScene = preload("res://scenes/NoodleItem.tscn")

func _on_interactable_interacted(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		if body.get_node("ItemSlot").get_child_count() > 0:
			$INTERACTABLE.can_interact = true
			if $slot.get_child_count() > 0:
				if $slot.get_child(0).get_meta("type") == "Noodle" or $slot.get_child(0).get_meta("type") == "Topping" && $slot.get_child(0).get_meta("type") != body.get_node("ItemSlot").get_child(0).get_meta("type"):
					# PLAYER HAS SMTH IN HIS INV AND SO THE TABLE THAT MATCHES, HE CAN COMBINE IT
					Globals.log("Received "+str(body.get_node("ItemSlot").get_child(0).get_meta("type")))
					Globals.log("Got "+str($slot.get_child(0).get_meta("type")))
					var topping_id = 0
					var noodle_id = 0
					if body.get_node("ItemSlot").get_child(0).get_meta("type") == "Noodle":
						# GET TOPPINGNUM FROM SLOT
						topping_id = $slot.get_child(0).ToppingType
						noodle_id = body.get_node("ItemSlot").get_child(0).NoodleType
					else:
						# GET TOPPINGNUM FROM PLAYER
						topping_id = body.get_node("ItemSlot").get_child(0).ToppingType
						noodle_id = $slot.get_child(0).NoodleType
					
					#DELETING & CREATE NEW
					body.get_node("ItemSlot").get_child(0).queue_free()
					$slot.get_child(0).queue_free()
					var new_noodle = NoodleScene.instantiate()
					new_noodle.Price = Globals.noodle_types[noodle_id]["price"] + Globals.noodle_toppings[topping_id]["price"]
					new_noodle.NoodleType = noodle_id
					new_noodle.NoodleTopping = topping_id
					new_noodle.set_meta("tooltip",Globals.noodle_types[noodle_id]["name"]+" with "+Globals.noodle_toppings[topping_id]["name"])
					new_noodle.set_meta("description", "Good combination! Costs "+str(new_noodle.Price))
					$slot.add_child(new_noodle)
			else:
				if body.get_node("ItemSlot").get_child_count() > 0:
					if body.get_node("ItemSlot").get_child(0).get_meta("type") == "Noodle" or body.get_node("ItemSlot").get_child(0).get_meta("type") == "Topping" or body.get_node("ItemSlot").get_child(0).get_meta("type") == "ToppingRaw":
						
						# PLAYER HAS SMTH IN HIS INV BUT NOT THE TABLE
						
						body.get_node("ItemSlot").get_child(0).reparent($slot)
						$slot.get_child(0).position = Vector2(0,0)
						$slot.get_child(0).global_position = $slot.global_position
		else:
			if $slot.get_child_count() > 0:
				# PLAYER HAS NOTHING AND WANTS TO GRAB WHATS ON THE TABLE
				$slot.get_child(0).reparent(body.get_node("ItemSlot"))
				body.get_node("ItemSlot").get_child(0).position = Vector2(0,0)
				body.get_node("ItemSlot").get_child(0).global_position = body.get_node("ItemSlot").global_position
				pass
			

func _on_interactable_player_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		if body.get_node("ItemSlot").get_child_count() > 0:
			$INTERACTABLE.can_interact = true
			if $slot.get_child_count() > 0:
				if $slot.get_child(0).get_meta("type") == "Noodle" or $slot.get_child(0).get_meta("type") == "Topping" && $slot.get_child(0).get_meta("type") != body.get_node("ItemSlot").get_child(0).get_meta("type"):
					$INTERACTABLE.text = "Combine"
					$INTERACTABLE.can_interact = true
				else:
					$INTERACTABLE.can_interact = false
			else:
				if body.get_node("ItemSlot").get_child_count() > 0:
					if body.get_node("ItemSlot").get_child(0).get_meta("type") == "Noodle" or body.get_node("ItemSlot").get_child(0).get_meta("type") == "Topping" or body.get_node("ItemSlot").get_child(0).get_meta("type") == "ToppingRaw":
						$INTERACTABLE.text = "Place"
						$INTERACTABLE.can_interact = true
					else:
						$INTERACTABLE.can_interact = false
				else:
					$INTERACTABLE.can_interact = false
		else:
			if $slot.get_child_count() > 0:
				$INTERACTABLE.text = "Collect"
				$INTERACTABLE.can_interact = true
			else:
				$INTERACTABLE.can_interact = false
