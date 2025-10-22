extends Node2D
@export var cookingDuration: int = 5
@export var NoodleCooked: Node2D
@export var finished = false
@export var save_finished = false
@export var current_noodle_type = 0
var cooking = false

func _ready() -> void:
	NoodleCooked.hide()
	$Progressbar.hide()
	MachineSaver.add(self)
	if MachineSaver.has_saved(self):
		Globals.log("MACHINE SAVER: Found saved state for"+self.name)
		var saved_state = MachineSaver.restore_machine(self)
		Globals.log(self.name+" HAS NOODLETYPE: "+str(saved_state.current_noodle_type))
		Globals.log(self.name+" IS FINISHED: "+str(saved_state.finished))
		current_noodle_type = saved_state.current_noodle_type
		save_finished = saved_state.save_finished
		finished = save_finished
		if save_finished:
			$INTERACTABLE.can_interact = true
			NoodleCooked.global_position = $Product.global_position
			NoodleCooked.show()
			NoodleCooked.NoodleType = current_noodle_type
			$INTERACTABLE.text = "Collect Noodles"
	
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
			if itemslot.get_child(0).get_meta("type") == "RawNoodle":
				$AnimatedSprite2D.play("Cook")
				$INTERACTABLE.can_interact = false
				cooking = true
				current_noodle_type = itemslot.get_child(0).NoodleType
				itemslot.get_child(0).queue_free()
				save_finished = true
				await animate_progress_bar_down(cookingDuration)
				$AnimatedSprite2D.stop()
				$INTERACTABLE.can_interact = true
				NoodleCooked.global_position = $Product.global_position
				NoodleCooked.NoodleType = current_noodle_type
				NoodleCooked.show()
				$INTERACTABLE.text = "Collect Noodles"
				finished = true
				cooking = false
		else:
			if itemslot && itemslot.get_child_count() == 0 && finished:
				NoodleCooked.hide()
				var new_noodle: Node2D = NoodleCooked.duplicate()
				new_noodle.global_position = body.global_position
				itemslot.add_child(new_noodle)
				new_noodle.global_position = itemslot.global_position
				new_noodle.show()
				new_noodle.scale = Vector2(2,2)
				new_noodle.set("NoodleType", current_noodle_type)
				new_noodle.set("Price", Globals.noodle_types[current_noodle_type]["price"])
				new_noodle.set_meta("tooltip", Globals.noodle_types[current_noodle_type]["name"])
				new_noodle.set_meta("description", "Hot and yummy! Costs: "+str(Globals.noodle_types[current_noodle_type]["price"]))
				Globals.log("Set noodletype to "+str(current_noodle_type))
				finished = false
				save_finished = false
				$INTERACTABLE.text = "Cook Noodles"
			else:
				Globals.log("Cant collect cooked noodle, itemslot is full")

func _on_interactable_player_entered(body: Node2D) -> void:
	$INTERACTABLE.can_interact = false
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node_or_null("ItemSlot")
		if !finished && itemslot.get_child_count() > 0 && !cooking:
			if itemslot.get_child(0).get_meta("type", "") == "RawNoodle":
				$INTERACTABLE.can_interact = true
		elif finished && itemslot.get_child_count() == 0 && !cooking:
			$INTERACTABLE.can_interact = true
