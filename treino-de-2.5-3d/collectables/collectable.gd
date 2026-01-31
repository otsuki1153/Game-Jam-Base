extends RigidBody3D

@export var item_type: InventoryManager.Items 
@onready var area_3d: Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(item_type !=null, "item type required")
	area_3d.body_entered.connect(handle)

func handle(body):
	if body.is_in_group("player"):
		InventoryManager.add_item(item_type)
		queue_free()
