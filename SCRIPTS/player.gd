extends CharacterBody2D

const SPEED = 450
@export var PICKUP = false
@export var Tables: Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var active_tab: String = ""
@onready var slot: PackedScene = preload("res://scenes/slot.tscn")

var dir = "down"
@onready var backpack_container = $CanvasLayer/Backpack/HBoxContainer

func _ready() -> void:
	$CanvasLayer/StatusBar/Control/VISITORSTATUSBAR.Tables = Tables
	backpack_container.hide()
	$CanvasLayer/Backpack/ItemSlot.hide()
	

func setDir(direction: String, pickup: bool, moving: bool = true) -> void:
	var slot = $ItemSlot
	var backpack = $Backpack
	
	if pickup:
		slot.visible = true
	else:
		slot.visible = false
		
	match direction:
		"up":
			if moving:
				animated_sprite_2d.play("WALK_UP")
			else:
				animated_sprite_2d.play("IDLE_UP")
			slot.visible = false
			if Globals.bought_backpack:
				backpack.show()
			
		"down":
			self.move_child($ItemSlot, self.get_child_count() - 1)
			if moving:
				animated_sprite_2d.play("WALK_DOWN")
			else:
				animated_sprite_2d.play("IDLE_DOWN")
			slot.position = Vector2(0,10)
			backpack.hide()
		
		"left":
			animated_sprite_2d.flip_h = true
			if moving:
				animated_sprite_2d.play("WALK_SIDE")
			else:
				animated_sprite_2d.play("IDLE_SIDE")
			self.move_child($ItemSlot, 0)
			slot.position = Vector2(-3,10)
			backpack.hide()
			
		"right":
			animated_sprite_2d.flip_h = false
			if moving:
				animated_sprite_2d.play("WALK_SIDE")
			else:
				animated_sprite_2d.play("IDLE_SIDE")
			self.move_child($ItemSlot, 0)
			slot.position = Vector2(3,10)
			backpack.hide()

func _initialize_backpack() -> void:
	Globals.log("Refreshed inventory")
	for item in backpack_container.get_children():
		item.queue_free()
		
	var index := 0
	for item in $BackpackSlot.get_children():
		var new_slot = slot.instantiate()
		var item_copy = item.duplicate() as Node2D
		
		backpack_container.add_child(new_slot)
		new_slot.add_child(item_copy)
		
		item_copy.scale = Vector2(1, 1)
		item_copy.position = Vector2(25, 25)
		item_copy.show()
		
		new_slot.index = index
		new_slot.slot_clicked.connect(_on_slot_clicked)
		Globals.log("Connected slot: " + str(index))
		index += 1
		backpack_container.show()
		
func _physics_process(delta: float) -> void:
	var input_vec = Vector2.ZERO
	var slot = $ItemSlot
	
	if Input.is_action_pressed("player_move_up"):
		if not $FOOTSTEP.playing:
			$FOOTSTEP.play()
		input_vec.y -= 1
		dir = "up"
	elif Input.is_action_pressed("player_move_down"):
		if not $FOOTSTEP.playing:
			$FOOTSTEP.play()
		input_vec.y += 1
		dir = "down"
	if Input.is_action_pressed("player_move_right"):
		if not $FOOTSTEP.playing:
			$FOOTSTEP.play()
		input_vec.x += 1
		dir = "right"
	if Input.is_action_pressed("player_move_left"):
		if not $FOOTSTEP.playing:
			$FOOTSTEP.play()
		input_vec.x -= 1
		dir = "left"
	
	if Input.is_action_pressed("exit_build_mode"):
		Globals.buildMode = false
		Buildmode.active_tile = ""
		$CanvasLayer/BuildModeInfo.hide()
	
	if Globals.buildMode:
		$CanvasLayer/BuildModeInfo.show()
	else:
		$CanvasLayer/BuildModeInfo.hide()
	
	if slot.get_child_count() > 0:
		var item = slot.get_child(0)
		$CanvasLayer/Backpack/ItemSlot/name.text = item.get_meta("tooltip")
		$CanvasLayer/Backpack/ItemSlot.show()
		var ditem = item.duplicate()
		for item_td in $CanvasLayer/Backpack/ItemSlot/product.get_children():
			item_td.queue_free()
		$CanvasLayer/Backpack/ItemSlot/product.add_child(ditem)
		if ditem.get_meta("type") == "Noodle":
			ditem.scale = Vector2(4,4)
		else:
			ditem.scale = Vector2(0.85,0.85)
		ditem.position = Vector2(25,20)
	else:
		$CanvasLayer/Backpack/ItemSlot.hide()
		
	if Globals.bought_backpack == true and Globals.refresh_inv == true:
		_initialize_backpack()
		backpack_container.show()
	if input_vec == Vector2.ZERO and $FOOTSTEP.playing:
		$FOOTSTEP.stop()
	if input_vec != Vector2.ZERO:
		input_vec = input_vec.normalized() * SPEED
		velocity = input_vec
		move_and_slide()
		setDir(dir, PICKUP, true)
	else:
		velocity = Vector2.ZERO
		setDir(dir, PICKUP, false)
		
func _input(event):
	var slot = $ItemSlot
	if slot.get_children().size() > 0:
		PICKUP = true
		setDir(dir, PICKUP)
	if event.is_action_pressed("player_pickup"):
		if slot.get_children().size() > 0:
			PICKUP = true
			setDir(dir, PICKUP)
		else:
			PICKUP = !PICKUP
		
func _on_slot_clicked(slot_index: int):
	Globals.log("Slot pressed: " + str(slot_index))
	
	var backpack_slot = $BackpackSlot
	var item_slot = $ItemSlot
	
	if slot_index >= backpack_slot.get_child_count():
		Globals.log("Invalid slot indx")
		return
	
	if item_slot.get_child_count() > 0:
		return
	
	var item = backpack_slot.get_child(slot_index)
	backpack_slot.remove_child(item)
	item_slot.add_child(item)
	item.position = Vector2.ZERO
	item.show()
	_initialize_backpack()

func _on_area_player_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		Globals.log("ENTERED AREA: "+body.name)
		

func _on_area_player_body_exited(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		Globals.log("LEFT AREA: "+body.name)
