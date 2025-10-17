extends Node2D

@export var ToppingType: int

func _process(delta: float) -> void:
	if(ToppingType == 0):
		$TOPPING.hide()
	else:
		$TOPPING.show()
		$TOPPING.region_rect = Rect2(Globals.noodle_toppings[ToppingType]["id"] * 24 + 528,0,24,24)
		
	self.set_meta("tooltip", Globals.noodle_toppings[ToppingType]["name"])
	self.set_meta("description","Uncutted toppings! You should cut them!")
