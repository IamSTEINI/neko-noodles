extends CharacterBody2D
@export var speed := 100.0

var direction := 1
var cat_sprite: AnimatedSprite2D
var is_speaking = false
var is_paused = false
var next_tt := 0.0
var move_until := 0.0
var pause_until := 0.0

var sentences = [
	"Meow!",
	"I'm hungry...",
	"God, where can I buy rice?",
	"Purr...",
	"These prices are outrageous!",
	"Do they have tuna on sale?",
	"I swear I saw a mouse here once...",
	"My paws are killing me.",
	"Why is everything so far away?",
	"I need more fish... always more fish.",
	"Should I get milk or cream?",
	"Shopping again... sigh.",
	"Don't stare, I'm just browsing!",
	"Where's the seafood aisle?",
	"I forgot my wallet again, great.",
	"These humans have no taste.",
	"This basket’s heavier than it looks.",
	"Can’t shop on an empty stomach.",
	"Maybe I’ll just nap in aisle three.",
	"Ugh, fur everywhere again...",
	"Do I look like I can carry all this?",
	"I only came for one thing!",
	"Why is there no catnip section?",
	"Everything smells weird here.",
	"I need a bigger bag... or smaller paws."
]

func _ready() -> void:
	randomize()
	speed = randf_range(85, 115)
	$RichTextLabel.hide()
	if randf() < 0.5:
		cat_sprite = $BROWN_CAT
		$WHITE_CAT.hide()
	else:
		cat_sprite = $WHITE_CAT
		$BROWN_CAT.hide()
	
	direction = -1 if randf() < 0.5 else 1
	schedule_next_pause()
	schedule_next_talk()
	update_animation(false)

func _physics_process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	
	if current_time >= next_tt and not is_speaking and not is_paused:
		start_talking()
		return
	
	if current_time >= pause_until and is_paused:
		is_paused = false
		direction = -1 if randf() < 0.5 else 1
		schedule_next_pause()
		update_animation(false)
	
	if current_time >= move_until and not is_paused and not is_speaking:
		is_paused = true
		pause_until = current_time + randf_range(1.0, 4.0)
		velocity.y = 0
		update_animation(true)
		return
	
	if not is_paused and not is_speaking:
		velocity.y = speed * direction
		move_and_slide()
		
		if get_slide_collision_count() > 0:
			direction *= -1
			update_animation(false)
	else:
		velocity.y = 0

func schedule_next_pause() -> void:
	randomize()
	var current_time = Time.get_unix_time_from_system()
	move_until = current_time + randf_range(3.0, 15.0)

func schedule_next_talk() -> void:
	randomize()
	var current_time = Time.get_unix_time_from_system()
	next_tt = current_time + randf_range(10.0, 45.0)

func start_talking() -> void:
	is_speaking = true
	velocity.y = 0
	update_animation(true)
	say(sentences[randi() % sentences.size()])

func say(text: String) -> void:
	update_animation(true)
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
	is_paused = true
	pause_until = Time.get_unix_time_from_system() + randf_range(2.0, 5.0)
	schedule_next_talk()

func update_animation(idle: bool) -> void:
	if idle:
		cat_sprite.play("IDLE_DOWN")
	elif direction == -1:
		cat_sprite.play("WALK_UP")
	else:
		cat_sprite.play("WALK_DOWN")
