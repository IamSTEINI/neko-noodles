extends Node2D

@export var speed := 100.0
@export var rotation_speed := 90.0

var state := 0
var timer := 0.0
var t_rotation := 0.0

func _process(delta: float) -> void:
	timer += delta
	
	match state:
		0:
			position += Vector2.DOWN.rotated(deg_to_rad(rotation_degrees))*speed * delta
			if timer >= 12.0:
				timer = 0.0
				t_rotation = 180
				state = 1
		1:
			if abs(rotation_degrees -t_rotation) <= rotation_speed * delta:
				rotation_degrees = t_rotation
				timer = 0.0
				state = 2
			else:
				rotation_degrees += rotation_speed*delta*sign(t_rotation - rotation_degrees)
		2:
			position += Vector2.DOWN.rotated(deg_to_rad(rotation_degrees)) * speed * delta
			if timer >= 23.0:
				timer = 0.0
				t_rotation = 90
				state = 3
		3:
			if abs(rotation_degrees -t_rotation) <= rotation_speed * delta:
				rotation_degrees = t_rotation
				timer = 0.0
				state = 4
			else:
				rotation_degrees +=rotation_speed * delta * sign(t_rotation - rotation_degrees)
		4:
			position += Vector2.DOWN.rotated(deg_to_rad(rotation_degrees)) * speed * delta
			if timer >= 37.5:
				timer = 0.0
				t_rotation = 0
				state = 5
		5:
			if abs(rotation_degrees - t_rotation) <= rotation_speed * delta:
				rotation_degrees = t_rotation
				timer = 0.0
				state = 6
			else:
				rotation_degrees += rotation_speed*delta*sign(t_rotation-rotation_degrees)
		6:
			position += Vector2.DOWN.rotated(deg_to_rad(rotation_degrees)) * speed * delta
			if timer >= 30.0:
				self.queue_free()
				
				
