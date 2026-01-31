extends CharacterBody3D

@export var JUMP_FORCE:float = 15.0
@export var SPEED: float = 4.0
@export var acceleration: float = 14.0
@export var friction: float  = 30.0
@export var Gravidade: float = 24.0

@export var enemy: CharacterBody3D

@export var max_health: float = 10.0
@export var current_health: float = 10.0

@export var base_attack:float = 1.0

@onready var body: MeshInstance3D = $MeshInstance3D
@onready var hit_collision_pivot: Node3D = $HitCollisionPivot
@onready var hit_range: Area3D = $HitCollisionPivot/HitRange

var counter_combo_punch: int = 0
var counter_combo_kick: int = 0
var critical_damage: bool = false

var enemy_attacked: CharacterBody3D
var pushDirection: Vector3 
var push_intensity: float  = 10.0
var can_attack: bool = false
var paused: bool = false


func _ready() -> void:
	add_to_group("player")
	up_direction = Vector3.UP
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		paused = !paused
	
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#if Input.is_action_just_pressed("Left_mouse"):
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#mouse_delta = event.relative

#
#func cameraMovement(delta):
	#rotate_y(-mouse_delta.x * mouse_sensi)
	#
	#
	#cam_pivot.rotation.x += mouse_delta.y * mouse_sensi
	#cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-33),  deg_to_rad(33))
	#
	#mouse_delta = Vector2.ZERO
#


func _physics_process(delta: float) -> void:
	#cameraMovement(delta)
	attack(base_attack)
	gravity(delta)
	movement(delta)
	move_and_slide()


func gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Gravidade * delta
	else:
		velocity.y = 0
		

func attack(amount: float):
	if enemy_attacked == null:
		return
		
	var dir = enemy_attacked.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	if counter_combo_punch == 2 and counter_combo_kick == 0:
		critical_damage = true
		hit_range.scale = Vector3(3.0,3.0,3.0)
	elif counter_combo_kick == 2 and counter_combo_punch == 0:
		critical_damage = true
		hit_range.scale = Vector3(3.0,3.0,3.0)
	elif counter_combo_kick > 0 and counter_combo_punch > 0:
		critical_damage = false
		hit_range.scale = Vector3.ONE
		counter_combo_kick = 0
		counter_combo_punch = 0
	elif counter_combo_punch == 0 and counter_combo_kick == 0:
		critical_damage = false
		hit_range.scale = Vector3.ONE
	

	if can_attack:
		if Input.is_action_just_pressed("K(Soco)"):
			#toca animação de soco com impacto
			#toca som de soco com impacto
			if critical_damage == false:
				enemy_attacked.velocity += dir * push_intensity
				counter_combo_punch += 1
			else:
				enemy_attacked.velocity += (dir * push_intensity) * 2
				counter_combo_punch = 0
				counter_combo_kick = 0
				critical_damage = false
		elif Input.is_action_just_pressed("L(Chute)"):
			#toca animação de chute com impacto
			#toca som de chute com impacto
			if critical_damage == false:
				enemy_attacked.velocity += dir * push_intensity
				counter_combo_kick += 1
			else:
				enemy_attacked.velocity += (dir * push_intensity) * 2
				counter_combo_kick = 0
				counter_combo_punch = 0
				critical_damage = false
	else:
		if Input.is_action_just_pressed("K(Soco)"):
			#toca animação de soco sem impacto
			#toca som de soco sem impacto
			if critical_damage == false:
				counter_combo_punch += 1
			else:
				counter_combo_kick = 0
				counter_combo_punch = 0
				critical_damage = false
		elif Input.is_action_just_pressed("L(Chute)"):
			#toca animação de chute sem impacto
			#toca som de chute sem impacto
			if critical_damage == false:
				counter_combo_kick += 1
			else:
				counter_combo_kick = 0
				counter_combo_punch = 0
				critical_damage = false
	
	
	print("contador chute: ", counter_combo_kick)
	print("contador soco: ", counter_combo_punch)
	

func movement(delta: float) -> void:
	var inputDirZ := Input.get_axis("W", "S")
	var inputDirX := Input.get_axis("A", "D")
	
	var direction: Vector3 = Vector3(inputDirX, 0, inputDirZ)
	 
	#var forward := camera_3d.global_basis.z
	#var right := camera_3d.global_basis.x
	#direction.y = 0.0
	
	
	if !paused:
		direction = direction.normalized()
		
		if is_on_floor() and Input.is_action_just_pressed("Espaco"):
			velocity.y = JUMP_FORCE
			
			
		if direction != Vector3.ZERO:
			velocity.x = move_toward(velocity.x, direction.x * SPEED, acceleration * delta)
			velocity.z = move_toward(velocity.z, direction.z * SPEED, acceleration * delta)
			var target_angle = atan2(direction.x, direction.z)
			var look_target = global_position + direction
			body.rotation.y = lerp_angle(body.rotation.y, target_angle, 5.0 * delta)
			hit_collision_pivot.look_at(look_target, Vector3.UP)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			velocity.z = move_toward(velocity.z, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)


func _on_hit_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		print("inimigo entrou")
		enemy_attacked = body
		can_attack = true


func _on_hit_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		print("inimigo saiu")
		enemy_attacked = null
		can_attack = false


func health_update(amount):
	current_health -= amount
