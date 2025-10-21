extends Node

@export var sounds: Dictionary[String, AudioStreamMP3]

@onready var music: AudioStreamPlayer2D = $MUSIC
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var menutween: Tween
var currently_playing: String = "Nothing is playing"

func _ready() -> void:
	music.finished.connect(_on_music_finished)
	call_sound("Main Menu")

func call_sound(song: String) -> void:
	if currently_playing == song:
		return
	music.stop()
	music.stream = sounds[song]
	currently_playing = song
	music.play()
	$CanvasLayer/TextureRect/Song.text = song
	move_up()
	
func call_sound_with_fade(song: String) -> void:
	if currently_playing == song:
		return
	animation_player.play("fade")
	await get_tree().create_timer(0.5).timeout
	call_sound(song)
	animation_player.play_backwards("fade")

func _on_music_finished():
	var keys = sounds.keys()
	var current = keys.find(currently_playing)
	if current != -1:
		var next = (current + 1) % keys.size()
		call_sound_with_fade(keys[next])

func move_up():
	if menutween:
		menutween.kill()
	menutween = create_tween()
	menutween.set_ease(Tween.EASE_OUT)
	menutween.set_trans(Tween.TRANS_BACK)
	var orig_pos = 999
	menutween.tween_property($CanvasLayer/TextureRect, "position:y", orig_pos + 100, 0.2)
	menutween.tween_interval(0.2)
	menutween.tween_property($CanvasLayer/TextureRect, "position:y", orig_pos, 0.2)


func _on_skipping_pressed() -> void:
	music.stop()
	_on_music_finished()
