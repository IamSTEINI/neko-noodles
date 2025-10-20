extends Area2D

var noodle_item_scene = preload("res://scenes/NoodleItem.tscn")

func _on_body_entered(_body: Node2D) -> void:
	var slot = Globals.player_item_slot
	Globals.refresh_inv = true
	if slot.get_child_count() > 0:
		Globals.log("SLOT IS FULL")
	else:
		Globals.log("SLOT IS EMPTY, SERVING NOODLE")
	#Globals.refresh_inv = false
