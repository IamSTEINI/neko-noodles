extends AudioStreamPlayer2D
@export var add: int = 0
func _ready() -> void:
	while(true):
		self.volume_db = Globals.sfx_volume + add
		await get_tree().create_timer(0.2).timeout
