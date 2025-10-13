extends CanvasLayer
var last_scene_name: String
var scene_path = "res://scenes/"
var transfer_item: Node2D = null
@onready var animation: AnimationPlayer = $Transition


func _ready():
	hide()
	
func change_scene(from, to_scene: String) -> void:
	show()
	ShelfSaver.clear_shelves()
	last_scene_name = from.name
	animation.play("TRANSITION")
	Globals.log(from.name)
	if from.get_node("PLAYER"):
		Globals.log("Playerobj found, saving item")
		var player = from.get_node("PLAYER")
		if player.get_node("ItemSlot"):
			var slot = player.get_node("ItemSlot") as Node2D
			if slot.get_child_count() > 0:
				var item = slot.get_child(0)
				slot.remove_child(item)
				transfer_item = item
				add_child(transfer_item)
				transfer_item.hide()
				Globals.log("Saved "+str(transfer_item.name))
	var path = scene_path + to_scene + ".tscn"
	await animation.animation_finished
	get_tree().change_scene_to_file(path)
	await get_tree().tree_changed
	await get_tree().process_frame
	if to_scene == "Main":
		Npcmanager.restore_npc()
		Npcmanager.restore_table_states()
		ShelfSaver.restore_shelves()
	animation.play_backwards("TRANSITION")
	if transfer_item != null:
		call_deferred("_restore_item")

func _restore_item() -> void:
	var new_scene = get_tree().current_scene
	if new_scene:
		Globals.log("Now in: " + new_scene.name)
		if new_scene.get_node("PLAYER"):
			Globals.log("Playerobj found, restoring item")
			var player = new_scene.get_node("PLAYER")
			if player.get_node("ItemSlot"):
				var slot = player.get_node("ItemSlot") as Node2D
				if slot.get_child_count() == 0:
					remove_child(transfer_item)
					slot.add_child(transfer_item)
					transfer_item.position = Vector2.ZERO
					transfer_item.show()
					Globals.log("Playerobj found, restored item "+str(transfer_item.name))
					transfer_item = null
