extends Node2D
@export var level = 100

func _process(delta: float) -> void:
	var lv = clamp(level, 0.0, 100.0)
	var inverse = 100.0 - lv
	var ratio = inverse / 100.0
	var idx = int(round(ratio * float(31 - 1)))
	idx = clamp(idx, 0, 31 - 1)
	$bar.frame = idx
