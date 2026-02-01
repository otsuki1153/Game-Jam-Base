extends Node

signal health_changed(current, max_val)

var max_health: float = 10.0
var current_health: float = 10.0

func health_update(amount: float):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		print("player morto")
