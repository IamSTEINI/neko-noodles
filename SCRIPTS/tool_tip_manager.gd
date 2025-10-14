extends Node2D

@onready var tooltip_text = $CanvasLayer/TextureRect/Title
@onready var tooltip_desc = $CanvasLayer/TextureRect/Description

func _ready() -> void:
	$CanvasLayer.hide()
	tooltip_text.text = ""
	tooltip_desc.text = ""

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	
	params.position = mouse_pos
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var result = space_state.intersect_point(params)
	
	var tooltips = []
	var descriptions = []
	
	for hit in result:
		if hit.has("collider") and hit.collider:
			var node = hit.collider
			while node and node is Node:
				if node.has_meta("tooltip") and node.has_meta("description"):
					tooltips.append(str(node.get_meta("tooltip")))
					descriptions.append(str(node.get_meta("description")))
					break
				node = node.get_parent()
				
	var ui_under_mouse = get_viewport().gui_get_hovered_control()
	if ui_under_mouse:
		var ctrl = ui_under_mouse
		while ctrl:
			if ctrl.has_meta("tooltip") and ctrl.has_meta("description"):
				tooltips.append(str(ctrl.get_meta("tooltip")))
				descriptions.append(str(ctrl.get_meta("description")))
				break
			ctrl = ctrl.get_parent()
		
	if tooltips.size() > 0:
		$CanvasLayer.show()
		tooltip_text.text = tooltips[0]
		tooltip_desc.text = descriptions[0]
	else:
		tooltip_text.text = ""
		tooltip_desc.text = ""
		$CanvasLayer.hide()
