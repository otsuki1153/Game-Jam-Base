extends Node

signal game_paused(is_paused: bool)

var pause_input_action: String = "ui_cancel" 

func _enter_tree():
	print("DEBUG: PauseManager ha entrado al árbol.")

func _ready() -> void:
	print("DEBUG: PauseManager está listo (Ready).")
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(pause_input_action):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	
	var is_paused = get_tree().paused
	
	game_paused.emit(is_paused)
	
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("Pausa: Mouse Visible")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("Juego: Mouse Capturado")

	
