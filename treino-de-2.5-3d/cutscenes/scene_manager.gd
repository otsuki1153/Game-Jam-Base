extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func change_scene(target: String):
	animation_player.play("dissolve")
	await animation_player.animation_finished
	
	# 3. Cambiar la escena
	print("Cambiando a: ", target)
	get_tree().change_scene_to_file(target)
	
	# 4. Reproducir transición de entrada (Pantalla se aclara)
	# Importante: Usa play_backwards con el nombre explícito para evitar errores
	animation_player.play_backwards("dissolve")
	

func go_to_intro():
	change_scene("res://cutscenes/intro.tscn")
