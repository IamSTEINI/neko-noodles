extends CharacterBody2D

const SPEED = 450
@export var PICKUP = false
@export var Tables: Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var dir = "down"

func _ready() -> void:
	$CanvasLayer/StatusBar/Control/VISITORSTATUSBAR.Tables = Tables

func setDir(direction: String, pickup: bool, moving: bool = true) -> void:
	var slot = $ItemSlot

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

		"down":
			self.move_child($ItemSlot, self.get_child_count() - 1)
			if moving:
				animated_sprite_2d.play("WALK_DOWN")
			else:
				animated_sprite_2d.play("IDLE_DOWN")
			slot.position = Vector2(0,10)

		"left":
			animated_sprite_2d.flip_h = true
			if moving:
				animated_sprite_2d.play("WALK_SIDE")
			else:
				animated_sprite_2d.play("IDLE_SIDE")
			self.move_child($ItemSlot, 0)
			slot.position = Vector2(-3,10)

		"right":
			animated_sprite_2d.flip_h = false
			if moving:
				animated_sprite_2d.play("WALK_SIDE")
			else:
				animated_sprite_2d.play("IDLE_SIDE")
			self.move_child($ItemSlot, 0)
			slot.position = Vector2(3,10)


func _physics_process(delta: float) -> void:
	var input_vec = Vector2.ZERO
	
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
	
	if input_vec == Vector2.ZERO and $FOOTSTEP.playing:
		$FOOTSTEP.stop()
	if input_vec != Vector2.ZERO:
		input_vec = input_vec.normalized() * SPEED
		velocity = input_vec
		if !Globals.buildMode:
			move_and_slide()
			setDir(dir, PICKUP, true)
	else:
		velocity = Vector2.ZERO
		setDir(dir, PICKUP, false)
		
func _input(event):
	var slot = $ItemSlot
	if $ItemSlot.get_children().size() > 0:
		PICKUP = true
		setDir(dir, PICKUP)
	if event.is_action_pressed("player_pickup"):
		if $ItemSlot.get_children().size() > 0:
			PICKUP = true
			setDir(dir, PICKUP)
			Globals.log("[PLAYER] Pickup not possible since carrying item: " + str(PICKUP))
		else:
			PICKUP = !PICKUP
			Globals.log("[PLAYER] Pickup triggered: " + str(PICKUP))


func _on_area_player_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		Globals.log("ENTERED AREA: "+body.name)


func _on_area_player_body_exited(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		Globals.log("LEFT AREA: "+body.name)
