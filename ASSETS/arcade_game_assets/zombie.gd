extends CharacterBody2D

@export var speed := 100
@export var attack_range := 60
@export var player: CharacterBody2D
@export var cooldown := 0.8
@export var wave = 1

var is_animating_attack := false
var can_attack := true
var dead := false
var texts = ["OUCH!", "HELL NAH!", "GOD!", "SMASH!", "AHHH!"]

func _ready():
	speed = wave* 2 + speed
	$comictext.hide()
	$HeadArea.body_entered.connect(_on_head_hit)

func _physics_process(delta: float) -> void:
	if dead:
		if not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("die")
			$AnimatedSprite2D.frame = $AnimatedSprite2D.sprite_frames.get_frame_count("die") - 1
			$CollisionShape2D.disabled = true
		
		velocity.y += 1000 * delta
		move_and_slide()
		await get_tree().create_timer(3).timeout
		$Die.stop()
		self.queue_free()
		return
	
	if not player:
		$AnimatedSprite2D.play("idle")
		return
	
	var dx = player.global_position.x - global_position.x
	var h_distance = abs(dx)
	var dir_x := 0.0
	if h_distance > 0:
		dir_x = dx / h_distance
	
	if not is_animating_attack:
		if h_distance > attack_range - 5:
			velocity.x = dir_x * speed
			$AnimatedSprite2D.play("walk")
		elif h_distance <= attack_range and can_attack:
			velocity = Vector2.ZERO
			attack()
		else:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle")
	else:
		velocity = Vector2.ZERO
	
	velocity.y = 0
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		if player:
			$AnimatedSprite2D.flip_h = (player.global_position.x - global_position.x) < 0
	
	move_and_slide()


func attack() -> void:
	is_animating_attack = true
	can_attack = false
	$AnimatedSprite2D.play("attack")
	$Attack.play()
	
	var half_time = $AnimatedSprite2D.sprite_frames.get_frame_count("attack") / $AnimatedSprite2D.sprite_frames.get_animation_speed("attack") / 2.0
	await get_tree().create_timer(half_time).timeout
	
	if player and player.is_inside_tree() and player.has_method("die"):
		var dx = player.global_position.x - global_position.x
		if abs(dx) <= attack_range - 3:
			player.die()
	
	await $AnimatedSprite2D.animation_finished
	is_animating_attack = false
	await get_tree().create_timer(cooldown).timeout
	can_attack = true
	$Attack.stop()
	

func _on_head_hit(body: Node) -> void:
	if dead:
		return
	if body == player and player.velocity.y > 0:
		dead = true
		$Die.play()
		$Run.queue_free()
		player.kills += 1
		$AnimatedSprite2D.play("die")
		var t = $comictext.create_tween()
		$comictext.text = texts.pick_random()
		$comictext.show()
		var start_pos = $comictext.position
		t.tween_property($comictext, "position:y", start_pos.y - 30, 0.8)
		t.parallel().tween_property($comictext, "modulate:a", 0.0, 0.8)
		await t.finished
		$comictext.queue_free()
