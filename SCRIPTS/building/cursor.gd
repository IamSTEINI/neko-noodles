extends Node2D

@export var can = true

func _process(_delta: float) -> void:
	if Globals.buildMode or Buildmode.active_tile != "" and Buildmode.active_building != null:
		if can:
			$Cursor.show()
			$CursorDisabled.hide()
			$debug.show()
		else:
			$Cursor.hide()
			$CursorDisabled.show()
			$debug.show()
	else:
		$Cursor.hide()
		$CursorDisabled.hide()
		$debug.hide()
