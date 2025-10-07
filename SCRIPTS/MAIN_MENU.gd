extends Control

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Camera2D/AudioStreamPlayer2D

func _ready() -> void:
	#loop_background()
	$SETTINGS.hide()
#func loop_background() -> void:
	#var anim = $AnimationPlayer
	#while true:
		#anim.play("background")
		#await anim.animation_finished
		
func _on_texture_button_pressed() -> void:
	MusicManager.call_sound_with_fade("Main Theme")
	Scenemanager.change_scene($".", "Main")


func _process(delta: float) -> void:
	Globals.music_volume = $SETTINGS/HSlider.value - 40
	Globals.sfx_volume = $SETTINGS/HSlider2.value - 40
	$SETTINGS/HSlider/RichTextLabel.text = str((Globals.music_volume + 40) * 2)
	$SETTINGS/HSlider2/RichTextLabel.text = str((Globals.sfx_volume + 40) * 2)

func _on_settings_closed_button_pressed() -> void:
	$SETTINGS.hide()


func _on_settings_button_pressed() -> void:
	if $SETTINGS.visible :
		$SETTINGS.hide()
	else: $SETTINGS.show()
