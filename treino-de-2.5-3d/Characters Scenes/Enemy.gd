extends CharacterBody3D

@export var speed: float 
@export var gravity: float = 10
@export var friction : float 
@export var acceleration : float = 50


##----------------------------------  State Machine  ----------------------------------
@export var player: CharacterBody3D 

@onready var timer_to_stay: Timer = $timer_to_stay
@onready var timer_warking: Timer = $timer_warking
@onready var timer_turnig: Timer = $timer_turnig
@onready var frente: RayCast3D = $RayCast3D
@onready var vision: Area3D = $Vision

var direction : Vector3 = Vector3.ZERO

enum states {stay, patrol, turn, hunt}
var axis_turn: bool = false
var axis: bool = false
var actual_state = states.patrol

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	gravidade(delta)
	movement(delta)
	#state_machine(delta)
	move_and_slide()

func gravidade (delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

#func state_machine (delta):
	#match actual_state:
		#states.stay:
			#velocity.x = 0.0
			#velocity.z = 0.0
		#states.patrol:
			#if timer_to_stay.time_left == 0.0: 
				#timer_to_stay.start(25)
			#if axis_turn:
				#if axis:
					#velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta) 
					#frente.rotation.y = deg_to_rad(0.0)
					#vision.rotation.y = deg_to_rad(0.0)
					#if timer_warking.is_stopped():
						#timer_warking.start(5.0)
				#else:
					#velocity.x = move_toward(velocity.x, -(direction.x * speed), acceleration * delta )
					#frente.rotation.y = deg_to_rad(180.0)
					#vision.rotation.y = deg_to_rad(180.0)
					#if timer_warking.is_stopped():
						#timer_warking.start(5.0)
			#else:
				#if axis:
					#velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta) 
					#frente.rotation.y = deg_to_rad(90.0)
					#vision.rotation.y = deg_to_rad(90.0)
					#if timer_warking.is_stopped():
						#timer_warking.start(5.0)
				#else:
					#velocity.z = move_toward(velocity.z, -(direction.z * speed), acceleration * delta )
					#frente.rotation.y = deg_to_rad(270.0)
					#vision.rotation.y = deg_to_rad(270.0)
					#if timer_warking.is_stopped():
						#timer_warking.start(5.0)
			#if frente.is_colliding():
				#timer_warking.stop()
				#actual_state = states.turn
		#states.turn:
			#velocity.x = move_toward(velocity.x, 0.0,friction * delta) 
			#velocity.z = move_toward(velocity.z, 0.0,friction *  delta) 
			#if timer_turnig.time_left == 0.0:
				#timer_turnig.start(3.0)
		#states.hunt:
			#timer_warking.stop()
			#timer_turnig.stop()
			#timer_to_stay.stop()
			#var target : Vector3 = (player.global_position -  self.global_position)
			#target.y = 0.0
			#target = target.normalized()
			#var angle_target = atan2(target.x , target.z)
			#
			#velocity.x = move_toward(velocity.x, (target.x * speed), acceleration * delta)
			#velocity.z = move_toward(velocity.z, (target.z * speed), acceleration * delta)
			#self.rotation.y = lerp_angle(rotation.y, angle_target,0.5 * delta)
			


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player entrou")
		actual_state = states.hunt
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("player saiu")
		actual_state = states.patrol
		timer_turnig.start(3.0)
	


func _on_timer_turnig_timeout() -> void:
	axis_turn = !axis_turn
	actual_state = states.patrol


func _on_timer_warking_timeout() -> void:
	axis = !axis


func _on_timer_to_stay_timeout() -> void:
	actual_state = states.stay

func movement(delta):
	if not player:
		return
	
	else:
		var target : Vector3 = (player.global_position -  self.global_position).normalized()
		var angle_target = atan2(target.x , target.z)
		
		target.y = 0.0
		velocity.x = move_toward(velocity.x, (target.x * speed), acceleration * delta)
		velocity.z = move_toward(velocity.z, (target.z * speed), acceleration * delta)
		self.rotation.y = lerp_angle(rotation.y, angle_target,0.5 * delta)




func persecution():
	return
