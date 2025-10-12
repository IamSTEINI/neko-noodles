extends Node2D
@export var cookingDuration: int = 5
@export var NoodleCooked: Node2D
var finished = false
@export var current_noodle_type = 0

func _ready() -> void:
	NoodleCooked.hide()
	$Progressbar.hide()
	
func animate_progress_bar_down(duration: float) -> void:
	$Progressbar.show()
	var steps := 50
	var step_time := duration / steps
	var value_step := 100 / steps

	for i in range(steps):
		$Progressbar.level = 100 - (i * value_step)
		await get_tree().create_timer(step_time).timeout

	$Progressbar.level = 0
	$Progressbar.hide()

func _on_interactable_interacted(body: Node2D) -> void:
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node("ItemSlot")
		if !finished:
			$AnimatedSprite2D.play("Cook")
			$INTERACTABLE.can_interact = false
			if itemslot.get_child(0).get_meta("type") == "RawNoodle":
				current_noodle_type = itemslot.get_child(0).NoodleType
				itemslot.get_child(0).queue_free()
				await animate_progress_bar_down(cookingDuration)
				$AnimatedSprite2D.stop()
				$INTERACTABLE.can_interact = true
				NoodleCooked.global_position = $Product.global_position
				NoodleCooked.NoodleType = current_noodle_type
				$INTERACTABLE.text = "Collect Noodles"
				finished = true
		else:
			if itemslot && itemslot.get_child_count() == 0:
				NoodleCooked.hide()
				var new_noodle: Node2D = NoodleCooked.duplicate()
				new_noodle.global_position = body.global_position
				itemslot.add_child(new_noodle)
				new_noodle.global_position = itemslot.global_position
				new_noodle.scale = Vector2(2, 2)
				new_noodle.show()
				new_noodle.set("NoodleType", current_noodle_type)
				new_noodle.set("Price", Globals.noodle_types[current_noodle_type]["price"])
				Globals.log("Set noodletype to "+str(current_noodle_type))
				finished = false
				$INTERACTABLE.text = "Cook Noodles"
			else:
				Globals.log("Cant collect cooked noodle, itemslot is full")

func _on_interactable_player_entered(body: Node2D) -> void:
	$INTERACTABLE.can_interact = false
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node_or_null("ItemSlot")
		if itemslot:
			if !finished && itemslot.get_child_count() > 0:
				if itemslot.get_child(0).get_meta("type", "") == "RawNoodle":
					$INTERACTABLE.can_interact = true
			elif finished && itemslot.get_child_count() == 0:
				$INTERACTABLE.can_interact = true
