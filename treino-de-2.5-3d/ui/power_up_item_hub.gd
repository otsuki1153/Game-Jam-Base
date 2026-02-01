extends Panel
class_name PowerUpItemHub
@onready var label: Label = $Label

func set_info(text: String) -> void:
	label.text= text
	visible = true
