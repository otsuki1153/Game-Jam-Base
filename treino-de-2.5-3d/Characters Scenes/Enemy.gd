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
enum State { IDLE, CHASE, ATTACK, HURT, DEAD }
var current_state: State = State.IDLE

var current_health: float

func _ready() -> void:
	add_to_group("enemy")
	current_health = max_health
	
	# Buscamos al player de forma segura por grupo
	if not player:
		player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Verificación de muerte
	if current_health <= 0 and current_state != State.DEAD:
		die()
		return

	if current_state == State.DEAD: return

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
	
	# Si estamos cerca y el cooldown terminó
	if global
