extends Node3D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 20
@export var spawn_only_once: bool = false
@export var enemy_textures : Array [Texture2D]


var triggered: bool = false


func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !triggered:
		triggered = true
		await spawnEnemies()
		disableSpawner()
		
func spawnEnemies():
	var spawnPoints = $SpawnPoints.get_children()
	var radius := 50.0
	
	for i in range(max_enemies):
		if spawnPoints.is_empty():
			return
		
		var enemy = enemy_scene.instantiate()
		
		if enemy_textures.size() > 0:
			var random_texture = enemy_textures.pick_random()
			enemy.call_deferred("apply_texture", random_texture)
		
		var base_point = spawnPoints[i % spawnPoints.size()].global_position
		
		var offset = Vector3(
			randf_range(-radius, radius),
			0,
			(self.global_position.z * randf_range(-radius, radius) - self.global_position.y)
		)

		enemy.global_position = base_point + offset
		enemy.velocity = Vector3.ZERO
		
		enemy.set_physics_process(false)
		get_parent().add_child(enemy)
		await get_tree().create_timer(1.0).timeout
		enemy.set_physics_process(true)

func disableSpawner():
	await get_tree().create_timer(3.0).timeout
	$TriggerArea.monitoring = false
	$TriggerArea.monitorable = false
	await get_tree().create_timer(3.0).timeout
	queue_free()
