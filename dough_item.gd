extends Node2D

@export var doughType: int = 0

func _ready() -> void:
	$Sprite2D.region_rect = Rect2(doughType * 24 + 336, 0, 24,24)
