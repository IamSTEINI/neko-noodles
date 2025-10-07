extends Node2D

@export var NoodleType: int = 0

func _ready() -> void:
	$Sprite2D.region_rect = Rect2(NoodleType * 24 + 48, 0, 24,24)
