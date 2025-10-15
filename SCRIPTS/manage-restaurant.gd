extends GridContainer


func _on_manage_tab_button_down() -> void:
	$restaurant_name/INPUT.text = Globals.restaurant_name
	$noodle_base_price/INPUT.text = str(Globals.noodle_base_price)
	$"../Title".text = Globals.restaurant_name

func _on_input_text_changed(new_text: String) -> void:
	Globals.restaurant_name = new_text
	$"../Title".text = new_text


func _on_baseprice_input_text_changed(new_text: String) -> void:
	if new_text.is_valid_int():
		Globals.noodle_base_price = int(new_text)
