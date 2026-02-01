extends CharacterBody3D

@export_group("Movimiento")
@export var JUMP_FORCE: float = 15.0
@export var SPEED: float = 4.0
@export var acceleration: float = 14.0
@export var friction: float = 100.0
@export var gravity_force: float = 24.0

@export_group("Combate")
@export var base_attack: float = 1.0
@export var push_intensity: float = 10.0

# Contadores de combo
var combo_punch_count: int = 0
var combo_kick_count: int = 0
var is_critical_ready: bool = false 

# Nodos
@onready var body: Node3D = $"Chalu - LowPolly - Animacoes"
@onready var player_anim: AnimationPlayer = $"Chalu - LowPolly - Animacoes/AnimationPlayer"
@onready var hit_collision_pivot: Node3D = $HitCollisionPivot
@onready var hit_range: Area3D = $HitCollisionPivot/HitRange

# Variables de estado
var enemy_attacked: CharacterBody3D = null
var can_attack: bool = false
var paused: bool = false
var attacking: bool = false

func _ready() -> void:
	player_anim.animation_finished.connect(_on_animation_finished)
	up_direction = Vector3.UP

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # "ESC" por defecto
		paused = !paused
		# PauseManager.toggle_pause() # Si usas el manager global
	
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if paused: return
	
	apply_gravity(delta)
	handle_movement(delta)
	handle_attack_input()
	move_and_slide()
	
	# Debug de colisión de piso
	if is_on_floor():
		pass # print("En el piso")

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity_force * delta
		if !attacking:
			player_anim.current_animation = "Armature|Pulo"
	else:
		# Fuerza de presión constante para estabilizar is_on_floor()
		if velocity.y < 0:
			velocity.y = -0.1

func handle_movement(delta: float) -> void:
	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	if is_on_floor() and Input.is_action_just_pressed("Espaco"):
		velocity.y = JUMP_FORCE

	if direction != Vector3.ZERO:
		if !attacking and is_on_floor():
			player_anim.current_animation = "Armature|Correndo"
		
		velocity.x = move_toward(velocity.x, direction.x * SPEED, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, acceleration * delta)
		
		var target_angle = atan2(direction.x, direction.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_angle, 10.0 * delta)
		
		# El pivot de ataque sigue la dirección del movimiento
		var look_target = global_position + direction
		hit_collision_pivot.look_at(look_target, Vector3.UP)
	else:
		if !attacking and is_on_floor():
			player_anim.speed_scale = 1.0
			player_anim.current_animation = "Armature|Idle"
			
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

func handle_attack_input():
	if Input.is_action_just_pressed("K(Soco)"):
		perform_attack("punch")
	elif Input.is_action_just_pressed("L(Chute)"):
		perform_attack("kick")

func perform_attack(type: String):
	attacking = true
	player_anim.speed_scale = 4.0
	
	is_critical_ready = check_critical_state(type)
	
	# Animación según el tipo
	if type == "punch":
		player_anim.current_animation = "Armature|SocoForte" if is_critical_ready else "Armature|SocoFraco"
	else:
		player_anim.current_animation = "Armature|ChuteForte" if is_critical_ready else "Armature|ChuteFraco"
	
	# Detección de daño
	var enemies = hit_range.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy") and enemy.has_method("apply_Impact"):
			var impact_dir = (enemy.global_position - global_position).normalized()
			
			if is_critical_ready:
				impact_dir.y = 1.5
				enemy.apply_Impact(impact_dir, push_intensity * 2.0, true)
			else:
				impact_dir.y = 0.5
				enemy.apply_Impact(impact_dir, push_intensity, false)

	update_combo_counters(type, is_critical_ready)

func check_critical_state(type: String) -> bool:
	if type == "punch" and combo_punch_count >= 2: return true
	if type == "kick" and combo_kick_count >= 2: return true
	return false

func update_combo_counters(type: String, was_critical: bool):
	if was_critical:
		combo_punch_count = 0
		combo_kick_count = 0
	else:
		if type == "punch":
			combo_punch_count += 1
			combo_kick_count = 0
		else:
			combo_kick_count += 1
			combo_punch_count = 0

func health_update(amount):
	PlayerManager.health_update(amount)
	player_anim.current_animation = "Armature|Dano"
	attacking = true # Bloquea movimiento mientras recibe daño

func _on_animation_finished(anim_name: String):
	if "Soco" in anim_name or "Chute" in anim_name or "Dano" in anim_name:
		attacking = false
