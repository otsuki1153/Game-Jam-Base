extends Node

var active_timers = {}

signal power_up_added(power_up)
signal power_up_removed(power_up)

enum PowerUp { REDBULL }

const POWERUP_DURATION = {
	PowerUp.REDBULL: 3.0 #todo aumentar
}

func add_powerup(type: PowerUp):
	# restart timer if already exist
	if active_timers.has(type):
		active_timers[type].start() 
		print("Tiempo extendido para: ", type)
		return # Terminamos aquí

	# create timer if not exist
	var timer = Timer.new()
	timer.wait_time = POWERUP_DURATION.get(type, 5.0)
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	active_timers[type] = timer
	
	timer.timeout.connect(_on_powerup_finished.bind(type))
	
	power_up_added.emit(type)
	
	
func _on_powerup_finished(type: PowerUp):
	if active_timers.has(type):
		var timer = active_timers[type]
		timer.queue_free()
		active_timers.erase(type)
		
		print("PowerUp finalizado: ", type)
		power_up_removed.emit(type)

func has_powerup(type: PowerUp) -> bool:
	return active_timers.has(type)
