extends Area2D

var noodle_item_scene = preload("res://scenes/NoodleItem.tscn")

func _on_body_entered(body: Node2D) -> void:
	var slot = body.get_node("ItemSlot")
	if slot.get_child_count() > 0:
		Globals.log("SLOT IS FULL")
	else:
		Globals.log("SLOT IS EMPTY, SERVING NOODLE")
		var egg_ramen = preload("res://ASSETS/NOODLES/egg_ramen.tres")
		var noodle_instance = noodle_item_scene.instantiate()
		noodle_instance.noodle = egg_ramen 
		noodle_instance.position = Vector2(0, 0)
		body.get_node("ItemSlot").add_child(noodle_instance)
