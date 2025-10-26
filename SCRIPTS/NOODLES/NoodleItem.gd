extends Node2D

@export var Price: int
@export var NoodleType: int
@export var NoodleTopping: int
@export var chopsticks: bool


func _process(_delta: float) -> void:
	if(chopsticks):
		$CHOPSTICKS.show()
	else:
		$CHOPSTICKS.hide()
		
	if(NoodleType == 0):
		$NOODLE.hide()
	else:
		$NOODLE.show()
		$NOODLE.region_rect = Rect2(Globals.noodle_types[NoodleType]["id"] * 24,0,24,24)
		
	if(NoodleTopping == 0):
		$TOPPING.hide()
	else:
		$TOPPING.show()
		$TOPPING.region_rect = Rect2(Globals.noodle_toppings[NoodleTopping]["id"] * 24 + 192 ,0,24,24)
	
	if !self.has_meta("tooltip"):
		self.set_meta("tooltip", Globals.noodle_types[NoodleType]["name"])
		self.set_meta("description","Tasty noodles! Costs "+str(Globals.noodle_types[NoodleType]["price"]))
