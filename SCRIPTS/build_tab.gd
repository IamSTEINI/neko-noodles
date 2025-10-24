extends GridContainer

@export var build_option_scene: PackedScene = null
@export var tileset: TileSet = null

func update_build_options():
	for child in get_children():
		child.queue_free()
	
	var indx = 0
	for key in Buildmode.building_parts:
		var option = Buildmode.building_parts[key]
		Globals.log(key + " loaded from build option")
		
		var new_build_option = build_option_scene.instantiate()
		new_build_option.building_price = option["price"]
		new_build_option.building_name = key
		
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
			pass
		new_build_option.index = indx
		(new_build_option as TextureButton).option_clicked.connect(_on_build_option_pressed)
		add_child(new_build_option)
		indx += 1

func _on_build_tab_pressed() -> void: 
	update_build_options()

func _on_build_option_pressed(index: int):
	$"../../../..".hide()
	Globals.buildMode = true
	Globals.log("BUILDING Choosed "+str(index))
