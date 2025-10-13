extends Panel
@export var noodle_type: int
@export var noodle_name: String
@export var npc_m_w_t: int

var wait_time: float

func _ready() -> void:
	$NoodleItem.NoodleType = noodle_type
	$NoodleName.text = noodle_name
	
func _process(delta: float) -> void:
	if get_tree().current_scene != null:
		if get_tree().current_scene.name == "Main":
			wait_time += delta
			var remaining = max(npc_m_w_t - wait_time, 0)
			$Progressbar.size = Vector2((remaining / npc_m_w_t) * 325, 5)
			var minutes = int(remaining) / 60
			var seconds = int(remaining) % 60
			$Time.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
			if remaining < 1:
				queue_free()
