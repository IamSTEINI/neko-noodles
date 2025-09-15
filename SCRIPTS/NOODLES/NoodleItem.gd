extends Node2D

@export var noodle: Noodle
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if noodle:
		sprite.texture = noodle.texture
