extends Node2D

@export var NoodleType: int = 0

func _process(_delta: float) -> void:
	$Sprite2D.region_rect = Rect2(NoodleType * 24 + 24, 0, 24,24)
	self.set_meta("tooltip", Globals.noodle_types[NoodleType]["name"])
	self.set_meta("description","Tasty noodles! Costs "+str(Globals.noodle_types[NoodleType]["price"]))
