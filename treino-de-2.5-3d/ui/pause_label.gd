extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PauseManager.game_paused.connect(on_pause_toggle)

func on_pause_toggle(paused: bool):
	visible = paused
