extends Node2D

@export var capacity: int = 1;
@export var customers: int = 0;
@export var food_slots: Array[Marker2D] = []

func update_capacity_text() -> void:
	var left_slots = 0
	for slot in food_slots:
		if slot.get_child_count() <= 0:
			left_slots += 0
		else:
			left_slots += 1
	$CAPACITY.text = str(left_slots)+"/"+str(food_slots.size())

func _on_interactable_interacted(body) -> void:
	Globals.log(self.name+" | "+body.name+" interacted")
	var empty_slot = find_empty_slot()
	if empty_slot == null:
		Globals.log(self.name+" | All foodslots are used ("+str(food_slots.size())+")")
	else:
		var player_food_slot = body.get_node("ItemSlot")
		if player_food_slot.get_child_count() > 0:
			var noodle = player_food_slot.get_child(0)
			if noodle.get_meta("type") == "Noodle":
				if empty_slot.get_child_count() > 0:
					Globals.log(self.name+" | foodslot is used")
				else:
					Globals.log("SERVING TO "+self.name+":" + noodle.name)
					player_food_slot.remove_child(player_food_slot.get_node("NoodleItem"))
					noodle.scale = Vector2(5, 5)
					empty_slot.add_child(noodle)
					update_capacity_text()
		else:
			Globals.log("Player has no items to serve")
	
func find_empty_slot() -> Marker2D:
	for slot in food_slots:
		if slot.get_child_count() <= 0:
			return slot
	return null
	
func _ready() -> void:
	update_capacity_text()
	#Globals.log(self.name + " | food_slots array size: " + str(food_slots.size()))
	#for i in range(food_slots.size()):
		#Globals.log("  Slot " + str(i) + ": " + str(food_slots[i].name if food_slots[i] else "null"))


func _on_playercheck_body_entered(body: Node2D) -> void:
	update_capacity_text()
	if body.get_meta("type") == "player":
		if body.get_node("ItemSlot").get_child_count() > 0 && capacity <= customers:
			if body.get_node("ItemSlot").get_child(0).get_meta("type") == "Noodle":
				$INTERACTABLE.can_interact = true
		else:
			$INTERACTABLE.can_interact = false


func _on_playercheck_body_exited(body: Node2D) -> void:
	update_capacity_text()
	$INTERACTABLE.can_interact = false
