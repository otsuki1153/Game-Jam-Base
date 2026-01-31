extends Panel
class_name InventorItemHub
@onready var label: Label = $Label

func set_info(text: String) -> void:
	label.text= text
	visible = true
