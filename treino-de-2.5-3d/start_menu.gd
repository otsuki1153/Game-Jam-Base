extends Control

@onready var button: Button = $Button
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(func(): SceneManager.go_to_intro())
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	audio_stream_player.play(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
