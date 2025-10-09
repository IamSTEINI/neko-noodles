extends Node2D

@export var doughType: int = 0

func _ready() -> void:
	$Sprite2D.region_rect = Rect2(doughType * 24 + 336, 0, 24,24)
	self.set_meta("tooltip", Globals.noodle_types[doughType]["name"])
	self.set_meta("description", "Yummy noodle. Costs "+str(Globals.noodle_types[doughType]["price"]))
