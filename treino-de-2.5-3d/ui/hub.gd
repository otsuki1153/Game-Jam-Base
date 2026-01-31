extends CanvasLayer
class_name Hub
@export var inventory_item_scene: PackedScene
@onready var items_container: HBoxContainer = $Control/ItemsContainer

func _ready() -> void:
	PlayerManager.item_added.connect(add_item)


func add_item(item: PlayerManager.Items):
	var item_hub: InventorItemHub = inventory_item_scene.instantiate()
	items_container.add_child(item_hub)
	item_hub.set_info(str(item+1))
