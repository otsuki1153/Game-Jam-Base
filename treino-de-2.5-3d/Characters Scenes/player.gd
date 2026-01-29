extends CharacterBody3D

@export var JUMP_FORCE:float = 10.0 
@export var SPEED: float = 6.0
@export var acceleration: float = 20.0
@export var friction: float  = 30.0
@export var Gravidade: float = 30.0

func _ready() -> void:
	up_direction = Vector3.UP

func _physics_process(delta: float) -> void:
	Gravity(delta)
	Movement(delta)
	move_and_slide()


func Gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Gravidade * delta
	else:
		velocity.y = 0


func Movement(delta: float) -> void:
	var inputDir: Vector3 = Vector3.ZERO
	inputDir.x = Input.get_axis("ui_left", "ui_right")
	inputDir.z = Input.get_axis("ui_up", "ui_down")
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_FORCE
	
	#print("eixo x:", x)
	#print("eixo z:", z)
	if inputDir != Vector3.ZERO:
		inputDir = inputDir.normalized()
		velocity.x = move_toward(velocity.x, inputDir.x * SPEED, acceleration * delta)
		velocity.z = move_toward(velocity.z, inputDir.z * SPEED, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
		
	
	
