extends Node2D

@export var noodle: Noodle
@export var Price: int
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if noodle:
		sprite.texture = noodle.texture
		Price = noodle.price
