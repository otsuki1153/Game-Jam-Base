extends CharacterBody3D

@export var JUMP_FORCE:float = 7.0
@export var SPEED: float = 4.0
@export var acceleration: float = 14.0
@export var friction: float  = 18.0
@export var Gravidade: float = 24.0

@onready var cam_pivot: Node3D = $Cam_pivot
@onready var camera_3d: Camera3D = $Cam_pivot/Camera3D

@export var mouse_sensi: float = 0.005
@export var cameraRotation: Vector2 = Vector2.ZERO

var mouse_delta := Vector2.ZERO

func _ready() -> void:
	up_direction = Vector3.UP
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("Left_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative


func cameraMovement(delta):
	rotate_y(-mouse_delta.x * mouse_sensi)
	
	
	cam_pivot.rotation.x += mouse_delta.y * mouse_sensi
	cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-33),  deg_to_rad(33))
	
	mouse_delta = Vector2.ZERO



func _physics_process(delta: float) -> void:
	cameraMovement(delta)
	gravity(delta)
	movement(delta)
	move_and_slide()


func gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Gravidade * delta
	else:
		velocity.y = 0


func movement(delta: float) -> void:
	var inputDir := Input.get_vector("A", "D", "W", "S")
	
	 
	var forward := camera_3d.global_basis.z
	var right := camera_3d.global_basis.x
	var direction: Vector3 = forward * inputDir.y + right * inputDir.x
	direction.y = 0.0
	
	
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
	
	if direction:
		velocity = velocity.move_toward(direction * SPEED, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
