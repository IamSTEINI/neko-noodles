extends Node2D

@export var cuttingDuration: int = 5
var topping_obj: PackedScene = preload("res://scenes/raw_topping_item.tscn")
var ToppingRaw: Node2D
@export var finished = false
@export var save_finished = false
@export var current_topping_type = 0
var cutting = false

func _ready() -> void:
	ToppingRaw = topping_obj.instantiate()
	self.add_child(ToppingRaw)
	if ToppingRaw:
		ToppingRaw.hide()
	$Progressbar.hide()
	MachineSaver.add(self)
	if MachineSaver.has_saved(self):
		Globals.log("MACHINE SAVER: Found saved state for"+self.name)
		var saved_state = MachineSaver.restore_machine(self)
		Globals.log(self.name+" HAS TOPPINGTYPE: "+str(saved_state.current_topping_type))
		Globals.log(self.name+" IS FINISHED: "+str(saved_state.finished))
		current_topping_type = saved_state.current_topping_type
		save_finished = saved_state.save_finished
		finished = save_finished
		if save_finished:
			$INTERACTABLE.can_interact = true
			ToppingRaw.global_position = $Product.global_position
			$INTERACTABLE.text = "Collect "+Globals.noodle_toppings[current_topping_type]["name"]
			ToppingRaw.ToppingType = current_topping_type
			ToppingRaw.show()
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
			if itemslot.get_child(0).get_meta("type") == "ToppingRaw":
				$AnimatedSprite2D.play("Cut")
				$INTERACTABLE.can_interact = false
				cutting = true
				$sound.play()
				current_topping_type = itemslot.get_child(0).ToppingType
				Globals.log("Current topping: "+str(current_topping_type))
				itemslot.get_child(0).queue_free()
				save_finished = true
				await animate_progress_bar_down(cuttingDuration)
				$AnimatedSprite2D.stop()
				$INTERACTABLE.can_interact = true
				ToppingRaw.global_position = $Product.global_position
				$INTERACTABLE.text = "Collect "+Globals.noodle_toppings[current_topping_type]["name"]
				ToppingRaw.ToppingType = current_topping_type
				ToppingRaw.show()
				finished = true
				cutting = false
				$sound.stop()
		else:
			if body.has_meta("type") && body.get_meta("type") == "player":
				if itemslot && itemslot.get_child_count() == 0:
					ToppingRaw.hide()
					var new_topping: Node2D = ToppingRaw.duplicate()
					new_topping.global_position = body.global_position
					new_topping.scale = Vector2(0.5,0.5)
					new_topping.position = Vector2(0,0)
					new_topping.ToppingType = current_topping_type
					new_topping.show()
					itemslot.add_child(new_topping)
					Globals.log("Set toppingtype to "+str(new_topping.ToppingType))
					finished = false
					save_finished = false
					$INTERACTABLE.text = "Cut"
				else:
					Globals.log("Cant collect topping, itemslot is full")
					
					
func _on_interactable_player_entered(body: Node2D) -> void:
	$INTERACTABLE.can_interact = false
	if body.has_meta("type") && body.get_meta("type") == "player":
		var itemslot = body.get_node_or_null("ItemSlot")
		if itemslot && itemslot.get_child_count() > 0 && !cutting:
			if !finished && itemslot.get_child(0).get_meta("type", "") == "ToppingRaw":
				$INTERACTABLE.can_interact = true
		if finished && itemslot.get_child_count() == 0 && !cutting:
			$INTERACTABLE.can_interact = true
