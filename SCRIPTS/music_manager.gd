extends Node

@export var sounds: Dictionary[String, AudioStreamMP3]

@onready var music: AudioStreamPlayer2D = $MUSIC
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var currently_playing: String = "Nothing is playing"

func _ready() -> void:
	call_sound("Main Menu")

func call_sound(song: String) -> void:
	if currently_playing == song:
		return
	music.stop()
	music.stream = sounds[song]
	currently_playing = song
	music.play()
	
func call_sound_with_fade(song: String) -> void:
	if currently_playing == song:
		return
	animation_player.play("fade")
	await get_tree().create_timer(0.5).timeout
	call_sound(song)
	animation_player.play_backwards("fade")
