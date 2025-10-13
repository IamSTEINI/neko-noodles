extends TextureRect

@export var Tables: Node2D

func _process(delta: float) -> void:
	$RichTextLabel.text = str(Globals.npc_spawn_count - Globals.npc_spawned)
	#if(Tables):
		#var children = Tables.get_children()
		#if children.size() == 0:
			#
		#else:
			#var available_tables = []
			#for table in children:
				#if table.occupied:
					#available_tables.append(table)
			#if available_tables.size() == 0:
				#$RichTextLabel.text = "0"
			#$RichTextLabel.text = str(len(available_tables))
