extends CharacterBody2D

@export var speed := 200
@export var jump_velocity := -400
@export var wave: int = 1
var dead = false
@export var kills = 0

func die() -> void:
	if dead:
		return
	dead = true
	$CollisionShape2D.disabled = true
	$CanvasLayer/text.text = "You died!"
	$Defeat.play()
	await $Defeat.finished
	$Defeat.stop()
	
	get_parent().queue_free()

func _physics_process(delta: float) -> void:
	var input_dir := 0
	if Input.is_action_pressed("player_move_left"):
		input_dir -= 1
	if Input.is_action_pressed("player_move_right"):
		input_dir += 1
	velocity.x = input_dir * speed

	if Input.is_action_just_pressed("spacebar") and is_on_floor():
		velocity.y = jump_velocity
	
	if !dead:
		$CanvasLayer/text.text = "Wave "+str(wave)
	
	$CanvasLayer/kills.text = (str(kills) + " KILL" + ("" if kills <= 1 else "S"))
	
	if velocity.y != 0:
		$AnimatedSprite2D.play("jump")
		$Foodsteps.stop()
	elif velocity.x != 0:
		$AnimatedSprite2D.play("walk")
		if is_on_floor() and not $Foodsteps.playing:
			$Foodsteps.play()
	else:
		$AnimatedSprite2D.play("idle")
		$Foodsteps.stop()
	
	if get_parent().get_node_or_null("Zombies") == null:
		return
	var zombies = get_parent().get_node("Zombies").get_children()
	for zombie in zombies:
		if not zombie or not zombie.is_inside_tree():
			continue
		var direction = zombie.global_position.x - global_position.x
		if direction < 0:
			$CanvasLayer/zombiel.show()
		else:
			$CanvasLayer/zombiel.hide()
		if direction > 0:
			$CanvasLayer/zombier.show()
		else:
			$CanvasLayer/zombier.hide()
	
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	velocity.y += 1000 * delta
	$CanvasLayer/left.text = str(self.get_parent().get_node("Zombies").get_child_count()) + "/"+str(wave)+" left"
	move_and_slide()
