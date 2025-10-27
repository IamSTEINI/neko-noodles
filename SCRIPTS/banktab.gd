extends GridContainer

@export var interest : int = 5

func _ready() -> void:
	$currentplan.text = "No loan in progress right now."
	$info.hide()
	

func _on_bank_tab_pressed() -> void:
	if Globals.debt != 0:
		$currentplan.text = "Current plan: "+str(int(Globals.debt / Globals.debt_init_duration))+"c / day ("+str(Globals.debt_duration)+" left)"
		$info.text = "You already have a loan in progress!"
		$getLoan.disabled = true
	else:
		$info.hide()
		$currentplan.text = "No loan in progress right now."
		$getLoan.disabled = false


func _on_get_loan_pressed() -> void:
	if Globals.debt != 0:
		$info.text = "You already have a loan in progress!"
		$info.show()
		return
	var loan_amount_str : String = $loan_request/INPUT.text
	var loan_duration_str : String = $loan_duration/INPUT.text
	if not loan_amount_str.is_valid_int() or not loan_duration_str.is_valid_int():
		$info.text = "Please enter numbers!"
		$info.show()
		return
	var loan_amount = int(loan_amount_str)
	var interest_amount = int(round(loan_amount * 0.05))
	var total_amount = loan_amount + interest_amount
	var loan_duration = int(loan_duration_str)
	var required = int(round(loan_amount * 0.25))
	
	if Globals.money < required:
		$info.text = "You need at least 25% (" + str(required) + "c) of the loan amount."
		$info.show()
		return
	_on_bank_tab_pressed()
	
	Globals.money += loan_amount
	$info.text = "Loan approved for " + str(total_amount) + "c (with interest) over " + str(loan_duration) + " days."
	Globals.debt = total_amount
	Globals.debt_duration = loan_duration
	Globals.debt_init_duration = loan_duration
	$info.show()
	
