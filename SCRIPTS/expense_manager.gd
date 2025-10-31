extends GridContainer
@export var entryScene: PackedScene = null

func render_expenses(transactions):
	for child in self.get_children():
		if child.name != "sum":
			child.queue_free()
	var total = 0
	for transaction in transactions:
		var entry = entryScene.instantiate()
		entry.reason = transaction["reason"]
		entry.amount = transaction["amount"]
		total += entry.amount
		self.add_child(entry)
		self.move_child(entry, 0)
		
	$sum.text = str(total)
	if (total < 0):
		$sum.text = $sum.text
		$sum.add_theme_color_override("default_color", Color("e40031"))
	else:
		$sum.add_theme_color_override("default_color", Color("7aba00"))

func _on_expenses_tab_button_down() -> void:
	$"../Title".text = tr("EXPENSES")+"#"+str(Globals.day)
	render_expenses(Expenses.transactions)
