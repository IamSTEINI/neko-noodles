extends AudioStreamPlayer2D

var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.2

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	update_timer += delta
	if update_timer >= UPDATE_INTERVAL:
		update_timer = 0.0
		self.volume_db = Globals.music_volume
