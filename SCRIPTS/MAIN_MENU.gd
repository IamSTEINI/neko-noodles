extends Control


func _ready() -> void:
	loop_background()

func loop_background() -> void:
	var anim = $AnimationPlayer
	while true:
		anim.play("background")
		await anim.animation_finished
		
func _on_texture_button_pressed() -> void:
	Scenemanager.change_scene($".", "Main")
