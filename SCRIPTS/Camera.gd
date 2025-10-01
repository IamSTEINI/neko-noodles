extends Camera2D

func _process(delta: float) -> void:
	if(Globals.buildMode):
		reparent(%BuildingPos)
		zoom = Vector2(0.5, 0.5)
		position = %BuildingPos.position
	else:
		reparent($"..")
		zoom = Vector2(1, 1)
		position = Vector2(0,0)
