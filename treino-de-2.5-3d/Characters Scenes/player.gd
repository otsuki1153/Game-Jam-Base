extends CharacterBody3D

@export var JUMP_FORCE:float = 15.0
@export var SPEED: float = 4.0
@export var acceleration: float = 14.0
@export var friction: float = 100.0
@export var Gravidade: float = 24.0

@export var enemy: CharacterBody3D

@export var max_health: float = 10.0
@export var current_health: float = 10.0

@export var base_attack:float = 1.0

@onready var body: Node3D = $"Chalu - LowPolly - Animacoes"
@onready var player_anim: AnimationPlayer = $"Chalu - LowPolly - Animacoes/AnimationPlayer"

@onready var hit_collision_pivot: Node3D = $HitCollisionPivot
@onready var hit_range: Area3D = $HitCollisionPivot/HitRange

@onready var hit_collision: CollisionShape3D = $HitCollisionPivot/HitRange/HitCollision
@onready var critical_colision: CollisionShape3D = $HitCollisionPivot/HitRange/CriticalColision

var counter_combo_punch: int = 0
var counter_combo_kick: int = 0
var critical_damage: bool = false

var enemy_attacked: CharacterBody3D
var push_intensity: float = 10.0
var can_attack: bool = false
var paused: bool = false

var attacking: bool = false

func _ready() -> void:
	# Corregido: Referencia a player_anim para evitar confusión con el nodo Player
	player_anim.animation_finished.connect(_on_animation_finished)
	up_direction = Vector3.UP

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ESC"): # Asegúrate que "ESC" esté definido en Input Map
		paused = !paused
		get_tree().paused = paused # Integración con PauseManager si lo usas
	
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if paused: return
	
	attack(base_attack)
	apply_gravity(delta)
	movement(delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Gravidade * delta
		if !attacking:
			player_anim.current_animation = "Armature|Pulo"
	else:
		# Pequeña fuerza negativa para mantener is_on_floor() activo
		if velocity.y < 0:
			velocity.y = -0.1

func attack(amount: float):
	if enemy_attacked == null:
		return
		
	var dir = (enemy_attacked.global_position - global_position).normalized()
	
	# Lógica de estados de combo
	if counter_combo_punch == 2 or counter_combo_kick == 2:
		critical_damage = true
		hit_collision.disabled = true
		critical_colision.disabled = false
	else:
		critical_damage = false
		hit_collision.disabled = false
		critical_colision.disabled = true

	# Input de ataque
	if Input.is_action_just_pressed("K(Soco)") or Input.is_action_just_pressed("L(Chute)"):
		var is_punch = Input.is_action_just_pressed("K(Soco)")
		attacking = true
		player_anim.speed_scale = 4.0
		
		if is_punch:
			player_anim.current_animation = "Armature|SocoForte" if critical_damage else "Armature|SocoFraco"
		else:
			player_anim.current_animation = "Armature|ChuteForte" if critical_damage else "Armature|ChuteFraco"
		
		if can_attack:
			if critical_damage:
				var enemies = hit_range.get_overlapping_bodies()
				for e in enemies:
					if e.is_in_group("enemy") and e.has_method("apply_Impact"):
						var crit_dir = dir
						crit_dir.y = 2.0
						e.apply_Impact(crit_dir, push_intensity * 2.0, true)
				counter_combo_punch = 0
				counter_combo_kick = 0
			else:
				enemy_attacked.apply_Impact(dir, push_intensity, false)
				if is_punch: counter_combo_punch += 1 
				else: counter_combo_kick += 1

func movement(delta: float) -> void:
	var inputDir = Input.get_vector("A", "D", "W", "S")
	var direction = Vector3(inputDir.x, 0, inputDir.y).normalized()
	
	if is_on_floor() and Input.is_action_just_pressed("Espaco"):
		velocity.y = JUMP_FORCE
		
	if direction != Vector3.ZERO:
		if !attacking and is_on_floor():
			player_anim.current_animation = "Armature|Correndo"
		
		velocity.x = move_toward(velocity.x, direction.x * SPEED, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, acceleration * delta)
		
		var target_angle = atan2(direction.x, direction.z)
		body.rotation.y = lerp_angle(body.rotation.y, target_angle, 10.0 * delta)
		
		# Hacemos que el pivot de ataque mire hacia donde nos movemos
		var look_target = global_position + direction
		hit_collision_pivot.look_at(look_target, Vector3.UP)
	else:
		if !attacking and is_on_floor():
			player_anim.speed_scale = 1.0 # Idle usualmente es lento
			player_anim.current_animation = "Armature|Idle"
			
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

func _on_hit_range_body_entered(body_node: Node3D) -> void:
	if body_node.is_in_group("enemy"):
		enemy_attacked = body_node
		can_attack = true

func _on_hit_range_body_exited(body_node: Node3D) -> void:
	if body_node == enemy_attacked:
		enemy_attacked = null
		can_attack = false

func health_update(amount):
	current_health -= amount
	player_anim.current_animation = "Armature|Dano"

func _on_animation_finished(anim_name: String):
	if "Soco" in anim_name or "Chute" in anim_name or "Dano" in anim_name:
		attacking = false
