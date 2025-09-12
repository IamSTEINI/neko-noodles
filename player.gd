extends CharacterBody2D

const SPEED = 450
var PICKUP = false
var dir = "down"

@onready var p_u_idle = $p_u
@onready var p_d_idle = $p_d
@onready var p_l_idle = $p_l
@onready var p_r_idle = $p_r

@onready var p_u_idle_p = $p_u_p
@onready var p_d_idle_p = $p_d_p
@onready var p_l_idle_p = $p_l_p
@onready var p_r_idle_p = $p_r_p

func setDir(direction: String, pickup: bool) -> void:
	for sprite in [p_u_idle, p_d_idle, p_l_idle, p_r_idle,
				   p_u_idle_p, p_d_idle_p, p_l_idle_p, p_r_idle_p]:
		sprite.visible = false

	if pickup:
		match direction:
			"up": p_u_idle_p.visible = true
			"down": p_d_idle_p.visible = true
			"left": p_l_idle_p.visible = true
			"right": p_r_idle_p.visible = true
	else:
		match direction:
			"up": p_u_idle.visible = true
			"down": p_d_idle.visible = true
			"left": p_l_idle.visible = true
			"right": p_r_idle.visible = true


func _physics_process(delta: float) -> void:
	var input_vec = Vector2.ZERO
	
	if Input.is_action_pressed("player_move_up"):
		input_vec.y -= 1
		dir = "up"
	elif Input.is_action_pressed("player_move_down"):
		input_vec.y += 1
		dir = "down"
	elif Input.is_action_pressed("player_move_right"):
		input_vec.x += 1
		dir = "right"
	elif Input.is_action_pressed("player_move_left"):
		input_vec.x -= 1
		dir = "left"

	if input_vec != Vector2.ZERO:
		input_vec = input_vec.normalized() * SPEED

	velocity = input_vec
	if(!Globals.buildMode):
		move_and_slide()
		setDir(dir, PICKUP)


func _input(event):
	if event.is_action_pressed("player_pickup"):
		PICKUP = !PICKUP
		Globals.log("[PLAYER] Pickup triggered: " + str(PICKUP))

func _on_area_player_body_entered(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		Globals.log("ENTERED AREA: "+body.name)


func _on_area_player_body_exited(body: Node2D) -> void:
	if body.get_meta("type") == "player":
		Globals.log("LEFT AREA: "+body.name)
