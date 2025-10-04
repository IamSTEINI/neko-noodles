extends Panel
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _process(delta: float) -> void:
	var money: String = Globals.get_money_formatted()
	rich_text_label.text = money
