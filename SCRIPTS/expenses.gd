extends Node

var transactions = [
	
]

func get_transactions() -> Array:
	return transactions
	
func add_transaction(reason: String, amount: float) -> void:
	for txn in transactions:
		if txn["reason"] == reason:
			txn["amount"] = txn["amount"] + amount
			return
	transactions.append({"reason": reason, "amount": amount})
	
func edit_transaction(reason: String, new_amount: float) -> void:
	for txn in transactions:
		if txn["reason"] == reason:
			txn["amount"] = new_amount
			return
	Globals.log("Reason not found: " + reason)
	
func remove_transaction(reason: String) -> void:
	for i in range(transactions.size()):
		if transactions[i]["reason"] == reason:
			transactions.remove_at(i)
			return
	Globals.log("Reason not found: " + reason)
