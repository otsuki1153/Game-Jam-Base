extends CharacterBody3D

@export var JUMP_FORCE:float = 15.0
@export var SPEED: float = 4.0
@export var acceleration: float = 14.0
@export var friction: float  = 100.0
@export var Gravidade: float = 24.0

@export var enemy: CharacterBody3D

@export var max_health: float = 10.0
@export var current_health: float = 10.0

@export var base_attack:float = 1.0

@onready var body: Node3D = $"Chalu - LowPolly - Animacoes"
@onready var player: AnimationPlayer = $"Chalu - LowPolly - Animacoes/AnimationPlayer"


@onready var hit_collision_pivot: Node3D = $HitCollisionPivot
@onready var hit_range: Area3D = $HitCollisionPivot/HitRange

@onready var hit_collision: CollisionShape3D = $HitCollisionPivot/HitRange/HitCollision
@onready var critical_colision: CollisionShape3D = $HitCollisionPivot/HitRange/CriticalColision


var counter_combo_punch: int = 0
var counter_combo_kick: int = 0
var critical_damage: bool = false

var enemy_attacked: CharacterBody3D
var pushDirection: Vector3 
var push_intensity: float  = 10.0
var can_attack: bool = false
var paused: bool = false


var attacking:bool = false
var damaged: bool = false

func _ready() -> void:
	add_to_group("player")
	player.animation_finished.connect(_on_animation_finished)
	up_direction = Vector3.UP
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ESC"):
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
		player.current_animation = "Armature|Pulo"
	else:
		velocity.y = 0


func attack(amount: float):
	if enemy_attacked == null:
		return
	
	
	var dir = enemy_attacked.global_position - global_position
	
	dir = dir.normalized()
	
	if !enemy_attacked.attacked:
		if counter_combo_punch == 2 and counter_combo_kick == 0:
			critical_damage = true
			hit_collision.disabled = true
			critical_colision.disabled = false
		elif counter_combo_kick == 2 and counter_combo_punch == 0:
			critical_damage = true
			hit_collision.disabled = true
			critical_colision.disabled = false
		elif counter_combo_kick > 0 and counter_combo_punch > 0:
			critical_damage = false
			if !critical_colision.disabled and hit_collision.disabled:
				critical_colision.disabled = true
				hit_collision.disabled = false
			counter_combo_kick = 0
			counter_combo_punch = 0
		elif counter_combo_punch == 0 and counter_combo_kick == 0:
			critical_damage = false
			dir.y = 0.0
			hit_collision.disabled = false
			critical_colision.disabled = true
	

	if can_attack:
		if Input.is_action_just_pressed("K(Soco)"):
			#toca som de soco com impacto
			if critical_damage == false:
				attacking = true
				player.speed_scale = 4.0
				player.current_animation = "Armature|SocoFraco"
				enemy_attacked.apply_Impact(dir, push_intensity, false)
				counter_combo_punch += 1
			else:
				attacking = true
				player.speed_scale = 4.0
				player.current_animation = "Armature|SocoForte"
				var enemies = hit_range.get_overlapping_bodies()
				for enemy in enemies:
					if enemy.is_in_group("enemy") and enemy is CharacterBody3D:
						dir.y = 2.0
						enemy.apply_Impact(dir, push_intensity * 2.0, true)
				counter_combo_punch = 0
				counter_combo_kick = 0
				critical_damage = false
				hit_range.scale = Vector3.ONE
		elif Input.is_action_just_pressed("L(Chute)"):
			#toca animação de chute com impacto
			#toca som de chute com impacto
			if critical_damage == false:
				attacking = true
				player.speed_scale = 4.0
				player.current_animation = "Armature|ChuteFraco"
				enemy_attacked.apply_Impact(dir, push_intensity, false)
				counter_combo_kick += 1
			else:
				attacking = true
				player.speed_scale = 4.0
				player.current_animation = "Armature|ChuteForte"
				var enemies = hit_range.get_overlapping_bodies()
				for enemy in enemies:
					if enemy.is_in_group("enemy") and enemy is CharacterBody3D:
						dir.y = 2.0
						enemy.apply_Impact(dir, push_intensity * 2.0, true)
				counter_combo_punch = 0
				counter_combo_kick = 0
				critical_damage = false
				hit_range.scale = Vector3.ONE
	#else:
		#if Input.is_action_just_pressed("K(Soco)"):
			##toca animação de soco sem impacto
			##toca som de soco sem impacto
			#if critical_damage == false:
				#attacking = true
				#player.speed_scale = 4.0
				#player.current_animation = "Armature|SocoFraco"
				#counter_combo_punch += 1
			#else:
				#player.speed_scale = 4.0
				#player.current_animation = "Armature|SocoForte"
				#counter_combo_kick = 0
				#counter_combo_punch = 0
				#critical_damage = false
		#elif Input.is_action_just_pressed("L(Chute)"):
			##toca animação de chute sem impacto
			##toca som de chute sem impacto
			#if critical_damage == false:
				#attacking = true
				#player.speed_scale = 4.0
				#player.current_animation = "Armature|ChuteFraco"
				#counter_combo_kick += 1
			#else:
				#attacking = true
				#player.speed_scale = 4.0
				#player.current_animation = "Armature|ChuteForte"
				#counter_combo_kick = 0
				#counter_combo_punch = 0
				#critical_damage = false


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
			if !attacking and !damaged:
				player.current_animation = "Armature|Correndo"
				attacking = false
				velocity.x = move_toward(velocity.x, direction.x * SPEED, acceleration * delta)
				velocity.z = move_toward(velocity.z, direction.z * SPEED, acceleration * delta)
				var target_angle = atan2(direction.x, direction.z)
				var look_target = global_position + direction
				body.rotation.y = lerp_angle(body.rotation.y, target_angle, 5.0 * delta)
				hit_collision_pivot.look_at(look_target, Vector3.UP)
		else:
			if !attacking and velocity.y == 0 and !damaged:
				player.speed_scale = 4.0
				player.current_animation = "Armature|Idle"
			
			velocity.x = move_toward(velocity.x, 0, (friction * delta) * 2)
			velocity.z = move_toward(velocity.z, 0, (friction * delta) * 2)
	else:
		velocity.x = move_toward(velocity.x, 0, (friction * delta) * 2)
		velocity.z = move_toward(velocity.z, 0, (friction * delta) * 2)


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
	damaged = true
	player.current_animation = "Armature|Dano"

func _on_animation_finished(anim_name: String):
	if anim_name.contains("Soco") or anim_name.contains("Chute"):
		attacking = false
		damaged = false

	if anim_name.contains("Dano"):
		damaged = false
		attacking = false
