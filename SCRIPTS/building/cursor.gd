extends Node2D

@export var can = true

func _process(_delta: float) -> void:
	if Globals.buildMode:
		if can:
			$Cursor.show()
			$CursorDisabled.hide()
		else:
			$Cursor.hide()
			$CursorDisabled.show()
	else:
		$Cursor.hide()
		$CursorDisabled.hide()
