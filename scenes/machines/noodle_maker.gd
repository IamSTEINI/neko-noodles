extends Node2D

@export var cuttingDuration: int = 5
var noodle_obj: PackedScene = preload("res://scenes/raw_noodle_item.tscn")
var NoodleRaw: Node2D
@export var finished = false
@export var save_finished = false
@export var current_noodle_type = 0
var cutting = false

func _ready() -> void:
	NoodleRaw = noodle_obj.instantiate()
	self.add_child(NoodleRaw)
	if NoodleRaw:
		NoodleRaw.hide()
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
			NoodleRaw.global_position = $Product.global_position
			$INTERACTABLE.text = "Collect Noodles"
			NoodleRaw.NoodleType = current_noodle_type
			NoodleRaw.show()

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
			if itemslot.get_child(0).get_meta("type") == "dough":
				$AnimatedSprite2D.play("Cut")
				$INTERACTABLE.can_interact = false
				cutting = true
				current_noodle_type = itemslot.get_child(0).doughType
				Globals.log("Current noodletype: "+str(current_noodle_type))
				itemslot.get_child(0).queue_free()
				save_finished = true
				await animate_progress_bar_down(cuttingDuration)
				$AnimatedSprite2D.stop()
				$INTERACTABLE.can_interact = true
				NoodleRaw.global_position = $Product.global_position
				$INTERACTABLE.text = "Collect Noodles"
				NoodleRaw.NoodleType = current_noodle_type
				NoodleRaw.show()
				finished = true
				cutting = false
		else:
			if body.has_meta("type") && body.get_meta("type") == "player":
				if itemslot && itemslot.get_child_count() == 0:
					NoodleRaw.hide()
					var new_noodle_raw: Node2D = NoodleRaw.duplicate()
					new_noodle_raw.global_position = body.global_position
					new_noodle_raw.scale = Vector2(0.5,0.5)
					new_noodle_raw.position = Vector2(0,0)
					new_noodle_raw.NoodleType = current_noodle_type
					new_noodle_raw.show()
					itemslot.add_child(new_noodle_raw)
					Globals.log("Set noodletype to "+str(new_noodle_raw.NoodleType))
					finished = false
					save_finished = false
					$INTERACTABLE.text = "Cut Noodles"
				else:
					Globals.log("Cant collect raw noodle, itemslot is full")


func _on_interactable_player_entered(body: Node2D) -> void:
	$INTERACTABLE.can_interact = false
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node_or_null("ItemSlot")
		if itemslot && itemslot.get_child_count() > 0 && !cutting:
			if !finished && itemslot.get_child(0).get_meta("type", "") == "dough":
				$INTERACTABLE.can_interact = true
		if finished && itemslot.get_child_count() == 0 && !cutting:
			$INTERACTABLE.can_interact = true
