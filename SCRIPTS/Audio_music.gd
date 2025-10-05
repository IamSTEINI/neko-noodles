extends AudioStreamPlayer2D

func _ready() -> void:
	while(true):
		self.volume_db = Globals.music_volume
		await get_tree().create_timer(0.2).timeout
