extends Node2D

@export var zombie_s: PackedScene = null
@export var zombie2_s: PackedScene = null
@export var spawn_points: Array[Node2D]
var wave: int = 1
var winterval := 1.5

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = winterval
	timer.one_shot = false
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_check_wave"))
	add_child(timer)

func _check_wave() -> void:
	$Player.wave = wave
	if $Zombies.get_child_count() == 0:
		new_wave()

func new_wave():
	wave += 1
	$Player.wave = wave
	if wave % 2 == 0:
		var spawns = spawn_points[randi() % spawn_points.size()]
		var zombie_lvl2 = zombie2_s.instantiate()
		zombie_lvl2.global_position = spawns.global_position
		zombie_lvl2.player = $Player
		$Zombies.add_child(zombie_lvl2)
	for i in range(wave-1 if wave % 2 == 0 else wave):
		var zombie = zombie_s.instantiate()
		
		if spawn_points.size() > 0:
			var spawn = spawn_points[randi() % spawn_points.size()]
			zombie.global_position = spawn.global_position
		else:
			zombie.global_position = Vector2.ZERO
		
		zombie.player = $Player
		zombie.wave = wave
		$Zombies.add_child(zombie)
