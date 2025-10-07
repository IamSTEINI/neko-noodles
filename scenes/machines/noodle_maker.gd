extends Node2D

@export var cuttingDuration: int = 5
@export var NoodleRaw: Node2D
var finished = false
@export var current_noodle_type = 0

func _ready() -> void:
	NoodleRaw.hide()

func _on_interactable_interacted(body: Node2D) -> void:
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node("ItemSlot")
		if !finished:
			$AnimatedSprite2D.play("Cut")
			$INTERACTABLE.can_interact = false
			if itemslot.get_child(0).get_meta("type") == "dough":
				current_noodle_type = itemslot.get_child(0).doughType
				itemslot.get_child(0).queue_free()
				await get_tree().create_timer(cuttingDuration).timeout
				$AnimatedSprite2D.stop()
				$INTERACTABLE.can_interact = true
				NoodleRaw.global_position = $Product.global_position
				NoodleRaw.show()
				$INTERACTABLE.text = "Collect Noodles"
				finished = true
		else:
			if body.has_meta("type") && body.get_meta("type") == "player":
				if itemslot && itemslot.get_child_count() == 0:
					NoodleRaw.hide()
					var new_noodle_raw: Node2D = NoodleRaw.duplicate()
					new_noodle_raw.global_position = body.global_position
					new_noodle_raw.scale = Vector2(0.5,0.5)
					itemslot.add_child(new_noodle_raw)
					new_noodle_raw.position = Vector2(0,0)
					new_noodle_raw.show()
					new_noodle_raw.set("NoodleType", current_noodle_type)
					Globals.log("Set noodletype to "+str(current_noodle_type))
					finished = false
					$INTERACTABLE.text = "Cut Noodles"
				else:
					Globals.log("Cant collect raw noodle, itemslot is full")


func _on_interactable_player_entered(body: Node2D) -> void:
	$INTERACTABLE.can_interact = false
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node_or_null("ItemSlot")
		if itemslot && itemslot.get_child_count() > 0:
			if !finished && itemslot.get_child(0).get_meta("type", "") == "dough":
				$INTERACTABLE.can_interact = true
		if finished && itemslot.get_child_count() == 0:
			$INTERACTABLE.can_interact = true
				
			
