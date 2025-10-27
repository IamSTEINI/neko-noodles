extends Node2D

func _ready() -> void:
	Globals.game_lost.connect(_on_game_lost)
	Dev.game_lost.connect(_on_game_lost)
	
func _on_game_lost() -> void:
	$AnimationPlayer.play("LOST")
	pass


func _on_retry_pressed() -> void:
	Globals.log("======================================")
	Globals.log("GAME RESET")
	Globals.log("======================================")
	Globals.money = 120
	Globals.debt = 0
	Globals.debt_init_duration = 0
	Globals.debt_duration = 0
	Globals.bought_backpack = false
	Globals.day = 1
	Globals.noodle_base_price = 0
	Globals.restaurant_name = "Your restaurant"
	Globals.restaurant_rating = 5.0
	Globals.time_accumulator = 0.0
	Globals.npc_spawn_count = 0
	Globals.npc_spawned = 0
	Globals.tutarrow_pos = Vector2(0,0)
	Globals.spawn_interval = 0
	Globals.spawn_accumulator = 0
	Globals.intime_seconds = 17 * 3600
	Globals.refresh_inv = true
	TileSaver.clear_saved_data()
	ShelfSaver.clear_shelves()
	MachineSaver.clear_saved()
	Npcmanager.clear()
	Speaking._ready()
	Globals.refresh_inv = false
	get_tree().change_scene_to_file("res://scenes/Main_Menu.tscn")
	$AnimationPlayer.play_backwards("LOST")
	#$get_tree().quit()
