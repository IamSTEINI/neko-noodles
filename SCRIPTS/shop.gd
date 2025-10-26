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


func _on_buy_button_pressed() -> void:
	$"../../../../../../../Click".play()
	if Globals.money >= price:
		Expenses.add_transaction("Shop", -price)
		Globals.money = Globals.money - price
		Globals.bought_backpack = true
		_on_shop_tab_pressed()
