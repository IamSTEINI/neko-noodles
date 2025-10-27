extends CharacterBody2D

var SPEED: int = 250
var JUMP_HEIGHT: int = -350
var dead: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("IDLE")

func _physics_process(delta: float) -> void:
	if dead:
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	velocity.x = 0
	if Input.is_action_pressed("player_move_left"):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("WALK_SIDE")
		velocity.x = -SPEED
	elif Input.is_action_pressed("player_move_right"):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("WALK_SIDE")
		velocity.x = +SPEED
	else:
		$AnimatedSprite2D.play("IDLE")
	if Input.is_action_pressed("spacebar") and is_on_floor():
		velocity.y = JUMP_HEIGHT
		
	
	move_and_slide()
	


func _on_die_body_entered(body: Node2D) -> void:
	dead = true
	$AnimatedSprite2D.play("DIE")
	await get_tree().create_timer(1).timeout
	position = Vector2(-1432.0,250)
	dead=false
