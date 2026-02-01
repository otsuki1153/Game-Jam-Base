extends RigidBody3D

@export var power_up_type: PowerUpManager.PowerUp 
@onready var area_3d: Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(power_up_type !=null, "power-up type required")
	area_3d.body_entered.connect(handle)

func handle(body):
	if body.is_in_group("player"):
		PowerUpManager.add_powerup(power_up_type)
		queue_free()
