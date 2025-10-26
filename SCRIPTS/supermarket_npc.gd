extends CharacterBody2D

@export var speed := 100.0
var direction := 1
var cat_sprite: AnimatedSprite2D
var is_speaking = false

var sentences = [
	"Meow!",
	"I'm hungry...",
	"God where can I buy rice",
	"Purr..."
]

func _ready() -> void:
	randomize()
	speed = randf_range(85, 115)

	if randf() < 0.5:
		cat_sprite = $BROWN_CAT
		$WHITE_CAT.hide()
	else:
		cat_sprite = $WHITE_CAT
		$BROWN_CAT.hide()

	start_movement_cycle()


func say(text: String) -> void:
	await wait_say()
	is_speaking = true
	$RichTextLabel.show()
	$Talking.play()
	$RichTextLabel.text = ""
	for i in range(text.length()):
		$RichTextLabel.text += text[i]
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(2.0).timeout
	$RichTextLabel.hide()
	$Talking.stop()
	is_speaking = false

func wait_say() -> void:
	while is_speaking:
		await get_tree().process_frame


func start_movement_cycle() -> void:
	while true:
		direction = -1 if randf() < 0.5 else 1
		update_animation(false)

		var move_time = randf_range(3.0, 16.0)
		var timer = get_tree().create_timer(move_time)

		while timer.time_left > 0.0:
			if randf() < 0.01 and not is_speaking:
				velocity.y = 0
				update_animation(true)
				await say(sentences[randi() % sentences.size()])
				timer = get_tree().create_timer(randf_range(1.0, 3.0))  # kurze Pause
			else:
				velocity.y = speed * direction
				move_and_slide()
				if get_slide_collision_count() > 0:
					direction *= -1
					update_animation(false)
			await get_tree().process_frame


func update_animation(idle: bool) -> void:
	if idle:
		cat_sprite.play("IDLE")
	elif direction == -1:
		cat_sprite.play("WALK_UP")
	else:
		cat_sprite.play("WALK_DOWN")
