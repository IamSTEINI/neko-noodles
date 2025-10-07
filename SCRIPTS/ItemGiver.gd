extends Area2D

var noodle_item_scene = preload("res://scenes/NoodleItem.tscn")

func _on_body_entered(body: Node2D) -> void:
	var slot = Globals.player_item_slot
	if slot.get_child_count() > 0:
		Globals.log("SLOT IS FULL")
	else:
		Globals.log("SLOT IS EMPTY, SERVING NOODLE")
