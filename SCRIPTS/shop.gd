extends GridContainer

var price: int = 10

func _on_shop_tab_pressed() -> void:
	if Globals.bought_backpack:
		$"BACKPACK-ITEM/Price".hide()
		$"BACKPACK-ITEM/BuyButton".hide()
		$"BACKPACK-ITEM/BoughtLabel".show()
	else:
		$"BACKPACK-ITEM/Price".show()
		$"BACKPACK-ITEM/BuyButton".show()
		$"BACKPACK-ITEM/BoughtLabel".hide()
	
	if Globals.bought_speed:
		$"SPEED/Price".hide()
		$"SPEED/BuyButton".hide()
		$"SPEED/BoughtLabel".show()
	else:
		$"SPEED/Price".show()
		$"SPEED/BuyButton".show()
		$"SPEED/BoughtLabel".hide()

func _on_buy_button_pressed() -> void:
	$"../../../../../../../Click".play()
	if Globals.money >= price:
		Expenses.add_transaction("Shop", -price)
		Globals.money = Globals.money - price
		Globals.bought_backpack = true
		_on_shop_tab_pressed()


func _on_speed_buy_button_pressed() -> void:
	$"../../../../../../../Click".play()
	if Globals.money >= price:
		Globals.money = Globals.money - price
		Globals.bought_speed = true
		_on_shop_tab_pressed()
