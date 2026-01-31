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

@export var player: CharacterBody3D 

@onready var frente: RayCast3D = $RayCast3D
@onready var attack_range: Area3D = $AttackRange

var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	add_to_group("enemies")
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
		player.current_health -= amount

func health_update(amount: float):
	current_health -= amount
	print(current_health)

func movement(delta):
	if not player:
		return
	
	else:
		persecution(delta)

func persecution(delta):
	var target : Vector3 = (player.global_position -  self.global_position).normalized()
	var angle_target = atan2(target.x , target.z)
	
	target.y = 0.0
	velocity.x = move_toward(velocity.x, (target.x * speed), acceleration * delta)
	velocity.z = move_toward(velocity.z, (target.z * speed), acceleration * delta)
	self.rotation.y = lerp_angle(rotation.y, angle_target,5.0 * delta)
