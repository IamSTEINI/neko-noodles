extends Node
@export var npc_scene: PackedScene
@export var coin_scene: PackedScene

@export var Tables: Node = null
@export var Entry: Node = null
@export var SpawnRanges: Node = null

func _ready():
	randomize()
	Globals.npc_spawn.connect(Callable(self, "spawn_npc"))
	
func _on_spawn_npc_pressed() -> void:
	spawn_npc()
	
func spawn_npc():
	var npc = npc_scene.instantiate()
	npc.Tables = Tables
	npc.Entry = Entry
	npc.coin_scene = coin_scene
	npc.SpawnRanges = SpawnRanges
	get_tree().current_scene.add_child(npc)
