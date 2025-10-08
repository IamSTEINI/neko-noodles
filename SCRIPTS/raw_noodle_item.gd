extends Node2D

@export var NoodleType: int = 0

func _process(delta: float) -> void:
	$Sprite2D.region_rect = Rect2(NoodleType * 24 + 24, 0, 24,24)
