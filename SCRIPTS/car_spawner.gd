extends Node2D

@export var car_scene: PackedScene = null

var timer := 0.0
var next_spawn := 0.0

func _ready() -> void:
	next_random()
func _process(delta: float) -> void:
	timer += delta
	if timer >= next_spawn:
		timer = 0.0
		_spawn_car()
		next_random()
	
func _spawn_car() -> void:
	if car_scene == null:
		return
	var car = car_scene.instantiate()
	car.position = position
	get_parent().add_child(car)
	
func next_random() -> void:
	next_spawn = randf_range(10.0,20.0)
