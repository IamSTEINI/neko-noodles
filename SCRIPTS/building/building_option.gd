extends TextureButton

@export var building_price: int = 1
@export var index: int = 0
@export var building_name: String = ""
@export var tag: String = ""
@export var building_sprite: Texture2D = null
@export var texture_scale: Vector2 = Vector2(1,1)

signal option_clicked(index: int)

func _ready() -> void:
	if building_sprite != null:
		if texture_scale != Vector2(1,1):
			$Sprite2D.scale = texture_scale
		$Sprite2D.texture = building_sprite
	$Price.text = str(building_price) + "c"
	$Name.text = building_name


func _on_pressed() -> void:
	emit_signal("option_clicked", index)
