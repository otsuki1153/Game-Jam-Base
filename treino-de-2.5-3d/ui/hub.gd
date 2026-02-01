extends CanvasLayer
class_name Hub
@export var inventory_item_scene: PackedScene
@export var powerup_item_scene: PackedScene
@onready var items_container: HBoxContainer = $Control/ItemsContainer
@onready var power_up_container: HBoxContainer = $Control/PowerUpContainer
@onready var life_bar: ProgressBar = $LifeBar
@onready var health_label: Label = $LifeBar/Label

var active_powerup_ui = {}

func _ready() -> void:
	PlayerManager.item_added.connect(add_item)
	PowerUpManager.power_up_added.connect(add_powerup_ui)
	PowerUpManager.power_up_removed.connect(remove_powerup_ui)
	
	HealthManager.health_changed.connect(update_health_ui)
	update_health_ui(HealthManager.current_health, HealthManager.max_health)


func add_item(item: PlayerManager.Items):
	var item_hub: InventorItemHub = inventory_item_scene.instantiate()
	items_container.add_child(item_hub)
	item_hub.set_info(str(item+1))
	
	
func add_powerup_ui(type: PowerUpManager.PowerUp):
	if active_powerup_ui.has(type):
		# Opcional-todo: flash animation, powerup restored
		return

	var powerup_node: PowerUpItemHub = powerup_item_scene.instantiate() 
	power_up_container.add_child(powerup_node)
	
	var powerup_name = PowerUpManager.PowerUp.keys()[type]
	powerup_node.set_info(powerup_name)
	
	active_powerup_ui[type] = powerup_node
	
func remove_powerup_ui(type: PowerUpManager.PowerUp):
	if not active_powerup_ui.has(type):
		return
		
	var powerup_node = active_powerup_ui[type]
	
	powerup_node.queue_free()
	
	active_powerup_ui.erase(type)

func update_health_ui(current: float, max_val: float):
	current -= 80
	life_bar.max_value = max_val 
	
	var tween = create_tween()
	tween.tween_property(life_bar, "value", current, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	health_label.text = str(int(current)) + " / " + str(int(max_val))
	
	if current < max_val * 0.25:
		life_bar.modulate = Color.RED
	else:
		life_bar.modulate = Color.GREEN
		
