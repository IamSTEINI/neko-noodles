extends Node2D

@export var capacity: int = 1;
@export var customers: int = 0;
@export var food_slots: Array[Marker2D] = []

func update_capacity_text() -> void:
	if customers < 0:
		customers = 0
	$CAPACITY.text = str(customers)+"/"+str(capacity)

func _on_interactable_interacted(body) -> void:
	Globals.log(self.name+" | "+body.name+" interacted")
	var empty_slot = find_empty_slot()
	if empty_slot == null:
		Globals.log(self.name+" | All foodslots are used ("+str(food_slots.size())+")")
	else:
		var player_food_slot = body.get_node("ItemSlot") as Marker2D
		if player_food_slot.get_child_count() > 0:
			var noodle = player_food_slot.get_child(0)
			if noodle.get_meta("type") == "Noodle":
				if empty_slot.get_child_count() > 0:
					Globals.log(self.name+" | foodslot is used")
				else:
					Globals.log("SERVING TO "+self.name+":" + noodle.name)
					noodle.position = Vector2(0,0)
					noodle.global_position = empty_slot.global_position
					noodle.reparent(empty_slot)
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
	#Globals.log(body.name) # Later check if NPC is AT the table
	update_capacity_text()
	if body.get_meta("type") == "player":
		var player_has_item = body.get_node("ItemSlot").get_child_count() > 0
		var player_has_noodle = player_has_item and body.get_node("ItemSlot").get_child(0).get_meta("type") == "Noodle"
		if player_has_noodle and customers > 0:
			$INTERACTABLE.can_interact = true
		else:
			$INTERACTABLE.can_interact = false


func _on_playercheck_body_exited(_body: Node2D) -> void:
	update_capacity_text()
	$INTERACTABLE.can_interact = false
