extends Node

signal game_paused(is_paused: bool)

var pause_input_action: String = "ui_cancel" 

func _enter_tree():
	print("DEBUG: PauseManager ha entrado al árbol.")

func _ready() -> void:
	print("DEBUG: PauseManager está listo (Ready).")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(pause_input_action):
		toggle_pause()

func toggle_pause() -> void:
	# Invertimos el estado actual
	var new_state = not get_tree().paused
	
	# Aplicamos el cambio al árbol entero
	get_tree().paused = new_state
	
	# Emitimos la señal para que la UI (el Hub) se entere
	game_paused.emit(new_state)
	
	print("Juego pausado: ", new_state)
