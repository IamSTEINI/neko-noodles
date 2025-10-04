extends AudioStreamPlayer2D

func _process(delta: float) -> void:
	self.volume_db = Globals.volume
