extends Node2D
@export var inventory: Array = []
@export var capacity: int = 8
@export var slot: PackedScene = null
var player_body: Node2D = null

func _ready() -> void:
	$InventoryUi.hide()
	ShelfSaver.shelves.append(self)
	update()

func update() -> void:
	$AnimatedSprite2D.frame = inventory.size()
	$RichTextLabel.text = str(inventory.size())+"/"+str(capacity)
	var needed = inventory.size()
	
	# Remove excess slots immediately- fkin bug made me loose an hour
	while $InventoryUi/GridContainer.get_child_count() > needed:
		var last_child = $InventoryUi/GridContainer.get_child($InventoryUi/GridContainer.get_child_count() - 1)
		$InventoryUi/GridContainer.remove_child(last_child)
		last_child.queue_free()
		
	while $InventoryUi/GridContainer.get_child_count() < needed:
		var new_slot = slot.instantiate()
		new_slot.connect("clicked_slot", Callable(self, "_on_slot_clicked_slot"))
		$InventoryUi/GridContainer.add_child(new_slot)
	
	for i in range(needed):
		var entry = inventory[i]
		var item_node = entry[1] as Node2D
		if item_node.get_parent():
			item_node.get_parent().remove_child(item_node)
		item_node.scale = Vector2(0.75,0.75)
		item_node.position = Vector2(12.5,12.5)
		if item_node.get_meta("type") == "Noodle":
			item_node.scale = Vector2(3,3)
		if item_node.get_meta("type") == "RawNoodle":
			item_node.scale = Vector2(0.5,0.5)
			item_node.position = Vector2(12.5,15)
		var target_slot = $InventoryUi/GridContainer.get_child(i)
		target_slot.add_child(item_node)
		

func _on_interactable_interacted(body: Node2D) -> void:
	player_body = body
	if body.get_meta("type") == "player":
		if body.has_node("ItemSlot"):
			if body.get_node("ItemSlot").get_child_count() == 1:
				if inventory.size() >= capacity:
					Globals.log("Inventory is full")
				else:
					var item = body.get_node("ItemSlot").get_child(0) as Node2D
					var item_name = item.name # OR LATER WITH META TAGS
					item.get_parent().remove_child(item)
					inventory.append([item_name, item])
					update()
					$InventoryUi.show()

func _on_interactable_player_entered(body: Node2D) -> void:
	player_body = body
	if body.get_meta("type") == "player":
		if body.has_node("ItemSlot"):
			if body.get_node("ItemSlot").get_child_count() > 0:
				$INTERACTABLE.can_interact = true
				update()
			else:
				$InventoryUi.show()

func _on_interactable_player_exited(body: Node2D) -> void:
	player_body = body
	if body.get_meta("type") == "player":
		$INTERACTABLE.can_interact = false
		$InventoryUi.hide()
		update()

func _on_slot_clicked_slot(index: Variant) -> void:
	if index < 0:
		return
	if index >= inventory.size():
		return
	if player_body.get_meta("type") == "player":
		if player_body.has_node("ItemSlot"):
			var player_item_slot = player_body.get_node("ItemSlot")
			if player_item_slot.get_child_count() > 0:
				Globals.log("Playeritemslot are full")
				return
	var grid_slot := $InventoryUi/GridContainer.get_child(index)
	if grid_slot.get_child_count() > 0:
		var item_node := grid_slot.get_child(0)
		if is_instance_valid(item_node):
			if player_body.get_meta("type") == "player":
				if player_body.get_node("ItemSlot"):
					item_node.reparent(player_body.get_node("ItemSlot"))
					(item_node as Node2D).position = Vector2(0,0)
					item_node.scale = Vector2(0.5,0.5)
					#item_node.position = Vector2(12.5,12.5)
					if item_node.get_meta("type") == "Noodle":
						item_node.scale = Vector2(2.5,2.5)
					if item_node.get_meta("type") == "RawNoodle":
						item_node.scale = Vector2(0.5,0.5)
					$INTERACTABLE.can_interact = true
	inventory.remove_at(index)
	update()
