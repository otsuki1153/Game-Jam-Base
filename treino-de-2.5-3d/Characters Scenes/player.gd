extends CharacterBody3D

@export var JUMP_FORCE:float = 15.0
@export var SPEED: float = 4.0
@export var acceleration: float = 14.0
@export var friction: float  = 30.0
@export var Gravidade: float = 24.0

@export var Life: float = 10.0

@onready var body: MeshInstance3D = $MeshInstance3D


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
	gravity(delta)
	movement(delta)
	move_and_slide()


func gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Gravidade * delta
	else:
		velocity.y = 0


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
			body.rotation.y = lerp_angle(body.rotation.y, target_angle, 5.0 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			velocity.z = move_toward(velocity.z, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
