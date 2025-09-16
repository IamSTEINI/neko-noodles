extends Node2D
@export var npc_scene: PackedScene

@export var Tables: Node = null
@export var Entry: Node = null
@export var Entry2: Node = null
@export var SpawnRanges: Node = null

func _ready():
	randomize()

func _on_spawn_npc_pressed() -> void:
	var npc = npc_scene.instantiate()
	npc.Tables = Tables
	npc.Entry = Entry
	npc.Entry2 = Entry2
	npc.SpawnRanges = SpawnRanges
	get_tree().current_scene.add_child(npc)
