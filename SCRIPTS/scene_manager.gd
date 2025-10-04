extends CanvasLayer
var last_scene_name: String
var scene_path = "res://scenes/"
@onready var animation: AnimationPlayer = $Transition


func _ready():
	hide()
	
func change_scene(from, to_scene: String) -> void:
	show()
	last_scene_name = from.name
	animation.play("TRANSITION")
	var path = scene_path + to_scene + ".tscn"
	await animation.animation_finished
	from.get_tree().call_deferred("change_scene_to_file", path)
	animation.play_backwards("TRANSITION")
	
