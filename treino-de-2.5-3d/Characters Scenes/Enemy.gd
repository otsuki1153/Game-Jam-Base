extends CharacterBody3D

@export_group("Stats")
@export var max_health: float = 100.0
@export var base_attack: float = 10.0
@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var rotation_speed: float = 10.0

@export_group("Physics")
@export var gravity: float = 9.8
@export var knockback_friction: float = 2.0

# Referencias
var player: Node3D = null 

@onready var enemy_model : MeshInstance3D = $"Enemy base - LowPolly - Animacoes/Armature/Skeleton3D/Personagem"
@onready var attack_timer: Timer = $Timer
@onready var raycast_frente: RayCast3D = $RayCast3D
@onready var attack_range: Area3D = $AttackRange

# --- Estados ---
enum State { IDLE, CHASE, ATTACK, HURT }
var current_state: State = State.IDLE

var current_health: float

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	
	# Buscamos al player de forma segura por grupo
	if not player:
		player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	match current_state:
		State.IDLE:
			logic_idle(delta)
		State.CHASE:
			logic_chase(delta)
		State.ATTACK:
			logic_attack(delta)
		State.HURT:
			logic_hurt(delta)
	
	move_and_slide()

# ---------------- LÓGICA DE ESTADOS ----------------

func logic_idle(_delta):
	velocity.x = move_toward(velocity.x, 0, acceleration * _delta)
	velocity.z = move_toward(velocity.z, 0, acceleration * _delta)
	
	if is_instance_valid(player):
		current_state = State.CHASE

func logic_chase(delta):
	if not is_instance_valid(player):
		current_state = State.IDLE
		return
		
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0 
	
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
	
	rotation_face_target(player.global_position, delta)
	
	# Si estamos cerca y podemos atacar
	if global_position.distance_to(player.global_position) < 2.0 and attack_timer.is_stopped():
		start_attack()

func logic_attack(_delta):
	velocity.x = move_toward(velocity.x, 0, acceleration * _delta)
	velocity.z = move_toward(velocity.z, 0, acceleration * _delta)

func logic_hurt(delta):
	velocity.x = move_toward(velocity.x, 0, knockback_friction * delta)
	velocity.z = move_toward(velocity.z, 0, knockback_friction * delta)

# ---------------- ACCIONES ----------------

func start_attack():
	if current_state == State.HURT: return
	
	current_state = State.ATTACK
	
	# Anticipación del ataque
	await get_tree().create_timer(0.3).timeout 
	
	if is_instance_valid(player) and raycast_frente.is_colliding():
		var collider = raycast_frente.get_collider()
		if collider == player:
			print("¡Toma na boca!")
			if collider.has_method("health_update"):
				collider.health_update(base_attack)
	
	attack_timer.start(2.0)
	
	if current_state == State.ATTACK:
		current_state = State.CHASE

func apply_Impact(dir: Vector3, force: float, is_critic: bool):
	current_state = State.HURT
	
	velocity = dir * force
	velocity.y = 4.0 if is_critic else 1.0
	
	var stun_time = 1.0 if is_critic else 0.3
	await get_tree().create_timer(stun_time).timeout
	
	if current_health > 0:
		current_state = State.CHASE

# Función útil para Powerups o efectos visuales de daño
func apply_texture(new_texture: Texture2D):
	if enemy_model:
		var new_material = StandardMaterial3D.new()
		new_material.albedo_texture = new_texture
		enemy_model.material_override = new_material
	else:
		print("Error: enemy_model no encontrado")

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0:
		velocity.y = -0.1

func rotation_face_target(target_pos: Vector3, delta: float):
	var target_flat = Vector3(target_pos.x, global_position.y, target_pos.z)
	if global_position.distance_to(target_flat) > 0.1:
		var new_transform = transform.looking_at(target_flat, Vector3.UP)
		transform = transform.interpolate_with(new_transform, rotation_speed * delta)

# ---------------- SEÑALES ----------------

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player and attack_timer.is_stopped():
		start_attack()

func _on_timer_timeout() -> void:
	# El timer ahora solo sirve para el cooldown
	pass
