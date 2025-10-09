extends CharacterBody2D

@export var speed = 1200.0

@export var Tables: Node = null
@export var Entry: Node = null
@export var SpawnRanges: Node = null

@export var Text: RichTextLabel = null
@export var TextBox: Control = null
@export var type_speed := 0.05
@export var show_duration := 2.0
@export var coin_scene: PackedScene

var reached_entry := false
var reached_table := false
var got_order := false
var chosen_table: Node2D = null
var SPAWN_LOC = null
var wait_time: float = 0.0
var food_slot = null
var is_speaking: bool = false
const NPC_MAX_WAITING_TIME: float = 60.0
var chosen_character: AnimatedSprite2D
@export var leaving = true
var generated_order: Array[int]

func generate_noodle() -> Array[int]:
	var noodle_index: int = (randi() % (Globals.noodle_types.size() - 1)) + 1
	# var topping_index: int = (randi() % (Globals.noodle_toppings.size() - 1)) + 1
	return [noodle_index, 0] # Returning 0 for topping for now
	
func toggle_collider(enable: bool) -> void:
	if enable:
		self.collision_mask |= 1 << 2
	else:
		self.collision_mask &= ~(1 << 2)

func _ready() -> void:
	randomize()
	if randi() % 2 == 0:
		chosen_character = $BROWN_CAT
	else:
		chosen_character = $WHITE_CAT
	chosen_character.show()
	TextBox.hide()
	var spawn_areas = SpawnRanges.get_children()
	var chosen_area = spawn_areas[randi() % spawn_areas.size()]
	var shape = chosen_area.shape as RectangleShape2D
	var extents = shape.extents
	generated_order = generate_noodle()
	var local_spawn_pos = Vector2(
		randf_range(-extents.x, extents.x),
		randf_range(-extents.y, extents.y)
	)
	$Order.hide()
	SPAWN_LOC = chosen_area.global_position + local_spawn_pos
	
	global_position = chosen_area.global_position + local_spawn_pos

	var pos1 = Entry.global_position

	$NavigationAgent2D.target_position = pos1
	
func pay(amount:int, table: Node2D) -> void:
	var coin = coin_scene.instantiate()
	coin.amount = amount
	coin.position = table.global_position
	get_tree().current_scene.add_child(coin)

func getRandomTable() -> Node2D:
	var children = Tables.get_children()
	if children.size() == 0:
		return null
	var available_tables = []
	for table in children:
		if table.capacity > table.customers:
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
	await wait_say()

	is_speaking = true
	TextBox.show()
	$Talking.play()
	Text.text = ""

	for i in range(text.length()):
		Text.text += text[i]
		await get_tree().create_timer(type_speed).timeout

	await get_tree().create_timer(show_duration).timeout
	TextBox.hide()
	$Talking.stop()
	is_speaking = false


func wait_say() -> void:
	while is_speaking:
		await get_tree().process_frame
	
func leave() -> void:
	reached_table = false
	$Order.hide()
	toggle_collider(false)
	$NavigationAgent2D.target_position = SPAWN_LOC
	await get_tree().create_timer(10.0).timeout
	queue_free()
	
func _physics_process(delta: float) -> void:
	if not $NavigationAgent2D.is_target_reached():
		var nav_point_dir = to_local($NavigationAgent2D.get_next_path_position()).normalized()
		velocity = nav_point_dir * speed * delta
		if !reached_table:
			if nav_point_dir.length() > 0.1:
				if abs(nav_point_dir.x) > abs(nav_point_dir.y):
					if nav_point_dir.x > 0:
						chosen_character.flip_h = false
						chosen_character.play("WALK_SIDEWAYS")
					else:
						chosen_character.flip_h = true
						chosen_character.play("WALK_SIDEWAYS")
				else:
					if nav_point_dir.y > 0:
						chosen_character.play("WALK_DOWN")
					else:
						chosen_character.play("WALK_UP")
			else:
				chosen_character.play("IDLE_DOWN")
		move_and_slide()
	else:
		if not reached_entry:
			chosen_table = getRandomTable()
			if chosen_table != null:
				food_slot = find_empty_slot(chosen_table.food_slots)
				chosen_table.customers += 1
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
			toggle_collider(true)
			wait_time = 0.0
			Globals.log("NPC WAITING FOR ORDER AT TABLE: " + str(chosen_table.name))
			chosen_character.play("IDLE_UP")
			if !got_order: 
				say("I want to order "+str(Globals.noodle_types[generated_order[0]]["name"]))
				$Order/OrderNoodle.NoodleType = generated_order[0]
				$Order/OrderNoodle.NoodleTopping = generated_order[1]
				$Order.show()
		elif reached_table and not got_order:
			wait_time += delta
			$Order/Progress.size = Vector2( ( (NPC_MAX_WAITING_TIME - wait_time) / NPC_MAX_WAITING_TIME ) * 50, 5 )
			if food_slot.get_child_count() > 0:
				for food in food_slot.get_children():
					if food.NoodleType == generated_order[0] && food.NoodleTopping == generated_order[1]:
						$Order.hide()
						Globals.log("NPC GOT ORDER AT TABLE: " + str(chosen_table.name))
						food.chopsticks = true
						got_order = true
					else:
						say("GRRR! That's not what I ordered")
						(food as Node2D).queue_free()
						leave()
			elif wait_time >= NPC_MAX_WAITING_TIME:
				say("GRRR! I'm leaving!")
				Globals.log("NPC LEFT ANGRY (timeout) at table: " + str(chosen_table.name))
				chosen_table.customers -= 1
				leave()
		
		elif got_order:
			await get_tree().create_timer(3).timeout # Simulating eating
			Globals.log("NPC FINISHED ORDER AT TABLE: " + str(chosen_table.name))
			chosen_table.customers -= 1
			for child in food_slot.get_children():
				Globals.log("NPC PAID: " + str(child.Price))
				pay(child.Price, chosen_table)
				child.queue_free()
				
			say("Yummy. Thank you!")
			leave()
