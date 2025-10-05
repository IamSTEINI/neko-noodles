extends Node

var console: RichTextLabel = null
var buildMode: bool = false
var tmultiplier: float = 480.0
var intime_seconds: int = 17 * 3600
var day: int = 1
var music_volume: int = 0
var sfx_volume: int = 0
var ingtime: String = "12:00 AM"
@export var money: int = 3000
var time_accumulator: float = 0.0
var npc_spawn_count := int(10 + sqrt(day) * 5.0)
var npc_spawned := 0
var spawn_interval := 0.0
var spawn_accumulator := 0.0
signal npc_spawn

func log(msg: String):
	if console:
		console.append_text(msg + "\n")
		console.scroll_to_line(console.get_line_count())

func _ready() -> void:
	update_time()
	Globals.log("DAY: " + str(day))
	calculate_spawn_interval()

func _process(delta: float) -> void:
	time_accumulator += delta * tmultiplier
	while time_accumulator >= 1.0:
		time_accumulator -= 1.0
		update_time()
	
	spawn_accumulator += delta * tmultiplier
	while spawn_accumulator >= spawn_interval:
		spawn_accumulator -= spawn_interval
		emit_signal("npc_spawn")
		npc_spawned += 1

func update_time() -> void:
	intime_seconds += 1

	var total_minutes = int(intime_seconds / 60)
	var hours_24 = int(total_minutes / 60) % 24

	if hours_24 >= 3 and hours_24 < 17:
		day += 1
		intime_seconds = 17 * 3600
		Globals.log("DAY: " + str(day))
		Globals.log("Skipping to night")

	var minutes = total_minutes % 60
	
	var am_pm = "AM"
	var hours_12 = hours_24
	if hours_24 >= 12:
		am_pm = "PM"
		if hours_24 > 12:
			hours_12 = hours_24 - 12
	if hours_12 == 0:
		hours_12 = 12

	ingtime = "%02d:%02d %s" % [hours_12, minutes, am_pm]
	
func calculate_spawn_interval():
	var virtual_day_seconds = 24 * 3600
	spawn_interval = virtual_day_seconds / max(npc_spawn_count, 1)
	spawn_accumulator = 0.0
	npc_spawned = 0
	
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
