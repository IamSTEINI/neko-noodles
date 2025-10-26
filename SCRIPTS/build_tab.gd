extends Control

@export var build_option_scene: PackedScene = null
@export var tileset: TileSet = null

var ordered_keys: Array[String] = []

func update_build_options():
	for child in $TextureRect/GridContainer/Restaurant/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	for child in $TextureRect/GridContainer/Tiles/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	for child in $TextureRect/GridContainer/Other/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	for child in $TextureRect/GridContainer/Machines/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	
	ordered_keys.clear()
	for key in Buildmode.building_parts.keys():
		ordered_keys.append(key)
	
	var indx = 0
	for key in ordered_keys:
		var option = Buildmode.building_parts[key]
		#Globals.log(key + " loaded from build option")
		var new_build_option = build_option_scene.instantiate()
		new_build_option.building_price = option["price"]
		new_build_option.building_name = option["name"]
		new_build_option.tag = option["tag"]
		
		if option["type"] == 0 or option["type"] == 1:
			if tileset == null:
				continue
			
			var atlas_coords: Vector2i = option["path"]
			var source_id = 0
			var source: TileSetSource = tileset.get_source(source_id)
			
			if source == null:
				continue
			
			if source is TileSetAtlasSource:
				var atlas_source = source as TileSetAtlasSource
				var atlas_texture = atlas_source.texture
				if atlas_texture == null:
					continue
				
				var tile_size = atlas_source.texture_region_size
				var separation = atlas_source.separation
				var margin = atlas_source.margins
				
				var region = Rect2(
					margin.x + atlas_coords.x * (tile_size.x + separation.x),
					margin.y + atlas_coords.y * (tile_size.y + separation.y),
					tile_size.x,
					tile_size.y
				)
				
				var tile_texture = AtlasTexture.new()
				tile_texture.atlas = atlas_texture
				tile_texture.region = region
				new_build_option.building_sprite = tile_texture
		
		elif option["type"] == 2:
			if option["path"] is PackedScene:
				var scene = option["path"] as PackedScene
				var instance = scene.instantiate()
				if instance.has_node("Sprite2D"):
					var sprite = instance.get_node("Sprite2D") as Sprite2D
					if sprite != null and sprite.texture != null:
						var texture = sprite.texture
						
						if sprite.region_enabled:
							var new_atlas = AtlasTexture.new()
							new_atlas.atlas = texture
							new_atlas.region = sprite.region_rect
							new_build_option.building_sprite = new_atlas
						elif texture is AtlasTexture:
							var atlas_tex = texture as AtlasTexture
							var new_atlas = AtlasTexture.new()
							new_atlas.atlas = atlas_tex.atlas
							new_atlas.region = atlas_tex.region
							new_build_option.building_sprite = new_atlas
						else:
							new_build_option.building_sprite = texture
				instance.queue_free()
		
		new_build_option.index = indx
		(new_build_option as TextureButton).option_clicked.connect(_on_build_option_pressed)
		if new_build_option.tag == "restaurant":
			$TextureRect/GridContainer/Restaurant/ScrollContainer/GridContainer.add_child(new_build_option)
		elif new_build_option.tag == "tiles":
			$TextureRect/GridContainer/Tiles/ScrollContainer/GridContainer.add_child(new_build_option)
		elif new_build_option.tag == "machines":
			$TextureRect/GridContainer/Machines/ScrollContainer/GridContainer.add_child(new_build_option)
		else:
			$TextureRect/GridContainer/Other/ScrollContainer/GridContainer.add_child(new_build_option)
			
		indx += 1

func _on_build_tab_pressed() -> void: 
	update_build_options()

func _on_build_option_pressed(index: int):
	$"../../../..".hide()
	Globals.buildMode = true
	
	if index < 0 or index >= ordered_keys.size():
		Globals.log("ERROR: Invalid index " + str(index))
		return
	
	var key = ordered_keys[index]
	
	if not key in Buildmode.building_parts:
		Globals.log("ERROR: Key not found: " + str(key))
		return
	
	var selected_building = Buildmode.building_parts[key]
	Buildmode.active_building_type = selected_building["type"]
	Buildmode.active_tile = key
	
	Globals.log("SET BUILDING TILE TO: " + str(key))
	Globals.log("SET BUILDING TYPE TO: " + str(selected_building["type"]))
