extends CharacterBody2D

@export var speed = 1200.0

@export var Tables: Node = null
@export var Entry: Node = null
@export var SpawnRanges: Node = null

@export var Text: RichTextLabel = null
@export var TextBox: Control = null
@export var type_speed := 0.05
@export var show_duration := 2.0

var reached_entry := false
var reached_table := false
var got_order := false
var chosen_table: Node2D = null
var SPAWN_LOC = null
var wait_time: float = 0.0
var food_slot = null
const NPC_MAX_WAITING_TIME: float = 10.0
@export var leaving = true

func _ready() -> void:
	randomize()
	TextBox.hide()
	var spawn_areas = SpawnRanges.get_children()
	var chosen_area = spawn_areas[randi() % spawn_areas.size()]
	var shape = chosen_area.shape as RectangleShape2D
	var extents = shape.extents
	
	var local_spawn_pos = Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)
	
	SPAWN_LOC = chosen_area.global_position + local_spawn_pos
	
	global_position = chosen_area.global_position + local_spawn_pos

	var pos1 = Entry.global_position

	$NavigationAgent2D.target_position = pos1

func getRandomTable() -> Node2D:
	var children = Tables.get_children()
	if children.size() == 0:
		return null
	var available_tables = []
	for table in children:
		if !table.occupied:
			available_tables.append(table)
	if available_tables.size() == 0:
		return null
	var chosen_table = available_tables[randi() % available_tables.size()] as Node2D
	return chosen_table

func find_empty_slot(food_slots) -> Marker2D:
	for slot in food_slots:
		if slot.get_child_count() <= 0:
			return slot
	return null

func say(text: String) -> void:
	TextBox.show()
	Text.text = ""
	for i in range(text.length()):
		Text.text += text[i]
		await get_tree().create_timer(type_speed).timeout
	await get_tree().create_timer(show_duration).timeout
	TextBox.hide()
	
func leave() -> void:
	$NavigationAgent2D.target_position = SPAWN_LOC
	await get_tree().create_timer(10.0).timeout
	queue_free()
	
func _physics_process(delta: float) -> void:
	if not $NavigationAgent2D.is_target_reached():
		var nav_point_dir = to_local($NavigationAgent2D.get_next_path_position()).normalized()
		velocity = nav_point_dir * speed * delta
		move_and_slide()
	else:
		if not reached_entry:
			chosen_table = getRandomTable()
			food_slot = find_empty_slot(chosen_table.food_slots)
			if chosen_table != null:
				chosen_table.occupied = true
				Globals.log("Table chosen: " + str(chosen_table.name))
				$NavigationAgent2D.target_position = chosen_table.global_position
				reached_entry = true
			else:
				Globals.log("No table available. Leaving")
				say("Seems full :(")
				leave()
		elif reached_entry and not reached_table and chosen_table != null:
			Globals.log("Table claimed: " + str(chosen_table.name))
			reached_table = true
			wait_time = 0.0
			Globals.log("NPC WAITING FOR ORDER AT TABLE: " + str(chosen_table.name))
			await get_tree().create_timer(1.5).timeout
			if !got_order: say("I want to order!")
		elif reached_table and not got_order:
			wait_time += delta
			if food_slot.get_child_count() > 0:
				got_order = true
				Globals.log("NPC GOT ORDER AT TABLE: " + str(chosen_table.name))
			
			elif wait_time >= NPC_MAX_WAITING_TIME:
				say("Too slow! I'm leaving >:(")
				Globals.log("NPC LEFT ANGRY (timeout) at table: " + str(chosen_table.name))
				chosen_table.occupied = false
				leave()
		
		elif got_order:
			Globals.log("NPC FINISHED ORDER AT TABLE: " + str(chosen_table.name))
			chosen_table.occupied = false
			for child in food_slot.get_children():
				Globals.log("NPC PAID: " + str(child.Price))
				Globals.money += child.Price
				child.queue_free()
			
			say("Yummy. Thank you!")
			leave()
