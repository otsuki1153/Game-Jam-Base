extends CharacterBody3D

#---------------------------------------  atributos ---------------------------------------

@export var speed: float 
@export var gravity: float = 10
@export var friction: float 
@export var acceleration: float = 10
@export var max_health: float
@export var base_attack: float

var current_health : float
var can_attack: bool = false
var attack_count : int = 0
var attack_delay : float
var attacked: bool = false


@onready var player: CharacterBody3D = $"../Player"

@onready var enemy_model : MeshInstance3D = $"Enemy base - LowPolly - Animacoes/Armature/Skeleton3D/Personagem"

@onready var timer: Timer = $Timer
@onready var frente: RayCast3D = $RayCast3D
@onready var attack_range: Area3D = $AttackRange


var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	add_to_group("enemy")
	can_attack = false
	current_health = max_health


func _physics_process(delta: float) -> void:
	gravidade(delta)
	movement(delta)
	attack(base_attack)
	move_and_slide()

func gravidade (delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

func apply_texture(new_texture: Texture2D):
	if enemy_model:
		var new_material = StandardMaterial3D.new()
		new_material.albedo_texture = new_texture
		enemy_model.material_override = new_material
	else:
		print("Erro: enemy_model não encontrado!")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player entrou")
		can_attack = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player saiu")
		can_attack = false

func attack(amount):
	
	if frente.is_colliding() and can_attack:
		print("toma na boca!!!")
		player.health_update(base_attack)
		timer.start(3.0)
		can_attack = false



func movement(delta):
	if not player:
		return
	
	else:
		persecution(delta)

func persecution(delta):
	var target : Vector3 = (player.global_position -  self.global_position).normalized()
	var angle_target = atan2(target.x , target.z)
	
	if !attacked:
		target.y = 0.0
		velocity.x = move_toward(velocity.x, (target.x * speed), acceleration * delta)
		velocity.z = move_toward(velocity.z, (target.z * speed), acceleration * delta)
		self.rotation.y = lerp_angle(rotation.y, angle_target,5.0 * delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0


func apply_Impact(dir: Vector3, force: float, critic: bool):
	set_collision_mask_value(2, false)
	await get_tree().create_timer(0.15).timeout
	set_collision_mask_value(2, true)
	
	if critic:
		velocity = dir * force
		velocity.y = 2.0
		await get_tree().create_timer(1.0).timeout
		attacked = true
		await get_tree().create_timer(3.0).timeout
		attacked = false
	else:
		velocity = dir * force
		velocity.y = 0.0
	
	
	

func _on_timer_timeout() -> void:
	can_attack = !can_attack
