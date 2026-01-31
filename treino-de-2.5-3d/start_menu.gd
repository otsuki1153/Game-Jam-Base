extends Control

@onready var button: Button = $Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(func(): SceneManager.go_to_intro())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
