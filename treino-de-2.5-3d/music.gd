extends Node2D

@onready var background_music :AudioStreamPlayer = $background_music

func _ready() -> void:
	configuratio_play()

func configuratio_play():
	var stream = background_music.stream
	
	if stream is AudioStreamOggVorbis:
		background_music.loop = true
		background_music.loop_offset = 25.0
