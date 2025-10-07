extends Node2D

func _ready() -> void:
	Globals.new_day_started.connect(_on_new_day_started)
	self.hide()

func _on_new_day_started(day: int) -> void:
	$"BG/DAY COUNT".text = str(day)
	$AnimationPlayer.play("NEW_DAY")
	self.show()
	await get_tree().create_timer(2).timeout
	$AnimationPlayer.play_backwards("NEW_DAY")
