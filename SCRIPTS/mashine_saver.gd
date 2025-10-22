extends Node2D

var machines: Dictionary = {}
var saved_machines: Dictionary = {}

func add(machine: Node) -> String:
	var machine_name = machine.name
	machines[machine_name] = machine
	Globals.log(machine.name+" added to savings")
	return machine_name
	
func get_machine(machine: Node) -> Node:
	return machines.get(machine.name, null)
	
func get_all_machines() -> Array:
	return machines.values()
	
func save_all_machines():
	saved_machines.clear()
	for machine_name in machines:
		var machine = machines[machine_name]
		if machine and is_instance_valid(machine):
			var duplicated = machine.duplicate(15)
			saved_machines[machine_name] = duplicated
		
func get_saved_machines() -> Dictionary:
	return saved_machines

func restore_machine(machine: Node) -> Node:
	if saved_machines.has(machine.name):
		return saved_machines[machine.name].duplicate(15)
	return null

func has_saved(machine: Node) -> bool:
	return saved_machines.has(machine.name)
