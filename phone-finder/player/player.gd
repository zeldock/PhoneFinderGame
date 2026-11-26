extends CharacterBody3D

var bob_time := 0.0
@export var bob_amount := 0.04
@export var bob_speed := 10.0
@onready var cam = get_viewport().get_camera_3d()
@onready var cam_base_y = cam.position.y

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var step_timer := 0.0
@export var step_interval := 0.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	var moving = Vector2(velocity.x, velocity.z).length() > 0.5
	if is_on_floor() and moving:
		step_timer -= delta
		if step_timer <= 0:
			$Footsteps.pitch_scale = randf_range(0.9, 1.1)
			$Footsteps.play()
			step_timer = step_interval
	else:
		step_timer = 0.0
		
	if is_on_floor() and moving:
		bob_time += delta * bob_speed
	else:
		bob_time = 0.0
	cam.position.y = lerp(cam.position.y, cam_base_y + sin(bob_time) * bob_amount, 10 * delta)
	
