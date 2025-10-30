extends Node

const next_day: int = 3
const day_start: int = 17
const early_time: float = 40.0 * 60.0

var restaurant_name = "Your restaurant"
var noodle_base_price = 0

var console: RichTextLabel = null
var buildMode: bool = false
var tmultiplier: float = 60.0 * 2
var intime_seconds: int = 17 * 3600 # 17
var day: int = 1
var music_volume: int = 0
var sfx_volume: int = 0
var ingtime: String = "12:00 AM"
var restaurant_rating: float = 5
var restaurant_rating_min: float = 0.1
@export var money: int = 120
@export var debt: int = 0
var debt_duration: int = 0
var debt_init_duration: int = 0

var time_accumulator: float = 0.0

var npc_spawn_count: int = 0
var npc_spawned: int = 0
var spawn_interval: float = 0.0
var spawn_accumulator: float = 0.0

var refresh_inv: bool = false
var tutarrow_pos: Vector2 = Vector2(0,42)

signal npc_spawn
signal new_day_started(day: int)
signal game_lost

# SHOP ITEMS

var bought_backpack = false
var bought_speed = false
var backpackCapacity = 3

var noodle_types = [
	{"name": "Empty", "id": 0, "price": 1},
	{"name": "Udon", "id": 2, "price": 1},
	{"name": "Soba", "id": 3, "price": 2},
	{"name": "Somen", "id": 4, "price": 1},
	{"name": "Hiyamugi", "id": 5, "price": 2},
	{"name": "Shirataki", "id": 6, "price": 3},
	{"name": "Yakisoba", "id": 7, "price": 3},
	{"name": "Harusame", "id": 8, "price": 2},
]

var noodle_toppings = [
	{"name": "Empty", "id": 0, "price": 0},
	{"name": "Ajitama", "id": 1, "price": 3},
	{"name": "Menma", "id": 2, "price": 3},
	{"name": "Negi", "id": 3, "price": 2},
	{"name": "Narutomaki", "id": 4, "price": 4},
	{"name": "Edamame", "id": 5, "price": 5},
]

func log(msg: String):
	if console:
		console.append_text(msg + "\n")
		console.scroll_to_line(console.get_line_count())

func _ready() -> void:
	update_time()
	Globals.log("DAY: " + str(day))
	_update_npc_count()
	calculate_spawn_i()

func tutorial():
	tutarrow_pos = Vector2(0,42)
	await Speaking.say("Hello, is that Timmy? I just wanted to wish you good luck again with the restaurant here in SHIBATOWN.")
	await Speaking.say("I'm going to tell you a few important things! So listen up!")
	Speaking.show_tip(1)
	tutarrow_pos = Vector2(1396.0,48)
	await Speaking.say("Ensure that guests are satisfied and get what they want for a good price!")
	tutarrow_pos = Vector2(208,42)
	await Speaking.say("You should place some tables for your customers to order noodles! Just press on the build tab in the menu bar and select the table!")
	tutarrow_pos = Vector2(208,165)
	Speaking.show_tip(2)
	await Speaking.say("Once you've done that, you should buy a noodle cutter, oven and so on! So that you can work properly!")
	tutarrow_pos = Vector2(0,42)
	await Speaking.say("To mix toppings with cooked noodles, you must place the noodles on a side table and then interact with the topping.")
	tutarrow_pos = Vector2(154,42)
	Speaking.show_tip(3)
	await Speaking.say("Oh and... Thank you for buying the restaurant from my parents. I think it's better if someone younger does the work now. I also wrote you a book, if you have any questions!")
	tutarrow_pos = Vector2(0,42)
	await Speaking.say("But maybe you'll get rich with it, Timmy... Can't wait to come visit you! See you then! You should propably go buying stuff now!")
	Speaking.show_tip(4)
	tutarrow_pos = Vector2(0,42)
	await Speaking.say("See you!")
	Speaking.show_tip(99)
	
func _process(delta: float) -> void:
	if get_tree().current_scene == null:
		return
		
	var is_main_scene := get_tree().current_scene.name == "Main"
	if not is_main_scene:
		return

	time_accumulator += delta * tmultiplier
	while time_accumulator >= 1.0:
		time_accumulator -= 1.0
		update_time()

	spawn_accumulator += delta * tmultiplier

	if spawn_interval <= 0.0:
		while npc_spawned < npc_spawn_count:
			emit_signal("npc_spawn")
			npc_spawned += 1
		calculate_spawn_i()
		return

	while spawn_accumulator >= spawn_interval and npc_spawned < npc_spawn_count:
		spawn_accumulator -= spawn_interval
		emit_signal("npc_spawn")
		npc_spawned += 1
		calculate_spawn_i()

func check_rating() -> void:
	if restaurant_rating < restaurant_rating_min:
		emit_signal("game_lost")
	pass

func kill_all_npcs():
	var children = get_tree().current_scene.get_children()
	for child in children:
		if child.has_meta("type"):
			if child.get_meta("type") == "NPC":
				child.queue_free()
	if get_tree().current_scene.get_node_or_null("TABLES") != null:
		for child in get_tree().current_scene.get_node("TABLES").get_children():
			child.customers = 0

func update_time() -> void:
	intime_seconds += 1

	var total_minutes = int(intime_seconds / 60)
	var hours_24 = int(total_minutes / 60) % 24

	if hours_24 >= next_day and hours_24 < day_start:
		day += 1
		if day % 7 == 0:
			# WEEKLY TRANSACTIONS
			Expenses.add_transaction("Rent (weekly)", -25)
			Globals.money = Globals.money - 25
			
		intime_seconds = day_start * 3600
		kill_all_npcs()
		Globals.log("DAY: " + str(day))
		emit_signal("new_day_started", day)
		_update_npc_count()
		spawn_accumulator = 0.0
		calculate_spawn_i()
		if debt != 0 and debt_duration != 0:
			Globals.money -= int(debt / debt_init_duration)
			debt_duration -= 1
			Expenses.add_transaction("Bank repayment", -int(debt / debt_init_duration))
			if debt_duration <= 0:
				debt = 0
				debt_duration = 0

	var minutes = total_minutes % 60
	
	var am_pm = "AM"
	var hours_12 = hours_24
	if hours_24 >= 12:
		am_pm = "PM"
		if hours_24 > 12:
			hours_12 = hours_24 - 12
	if hours_12 == 0:
		hours_12 = 12
	
	check_rating()
	ingtime = "%02d:%02d %s" % [hours_12, minutes, am_pm]

func _update_npc_count() -> void:
	npc_spawn_count = int(10 + sqrt(day) * 5.0)
	npc_spawned = 0

func seconds_until_next_day() -> float:
	var sec_in_day := intime_seconds % (24 * 3600)
	var next_day_sec := next_day * 3600

	if sec_in_day < next_day_sec:
		return float(next_day_sec - sec_in_day)
	if sec_in_day >= day_start * 3600:
		return float(24 * 3600 - sec_in_day + next_day_sec)
	return 0.0

func calculate_spawn_i() -> void:
	var remaining := float(max(npc_spawn_count - npc_spawned, 0))
	if remaining <= 0:
		spawn_interval = 1e9
		return

	var time_left := seconds_until_next_day()
	var available := float(max(0.0, time_left - early_time))

	if available <= 0.0:
		spawn_interval = 0.1
		return
	spawn_interval = available / float(remaining)
	if spawn_interval < 0.0001:
		spawn_interval = 0.0001
		
func get_ingame_time_formatted() -> String:
	return ingtime

func get_money_formatted() -> String:
	var abs_money = abs(money)
	var formatted := ""
	
	if abs_money >= 1_000_000:
		formatted = str("%.2f" % (money / 1_000_000.0)) + " mil"
	elif abs_money >= 10_000:
		formatted = str("%.2f" % (money / 10_000.0)) + "k"
	else:
		formatted = str(money)
	
	formatted = formatted.replace(".", ",")
	return formatted
