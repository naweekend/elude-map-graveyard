extends CharacterBody3D

@export var  SPEED = 5.0
@export var  JUMP_VELOCITY = 4.5
@export var  MOUSE_SENSITIVITY = 0.002

@onready var camera = $Camera3D

var camera_x_rotation := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate body left/right
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)

		# Rotate camera up/down
		camera_x_rotation -= event.relative.y * MOUSE_SENSITIVITY
		camera_x_rotation = clamp(camera_x_rotation, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = camera_x_rotation

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
