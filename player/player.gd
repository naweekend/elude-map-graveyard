extends CharacterBody3D

@export_group("Movement")
@export var BASE_SPEED: float = 10
@export var SPRINT_SPEED: float = 14
@export var JUMP_VELOCITY: float = 4.5
@export var MOUSE_SENSITIVITY: float = 0.002

@export_group("Headbob")
@export var headbob_frequency: float = 2.0
@export var headbob_amplitude: float = 0.07

var SPEED: float = BASE_SPEED
var headbob_time: float = 0.0
var camera_x_rotation := 0.0

@onready var camera = $Head/CameraPivot/Camera3D
@onready var footstep: AudioStreamPlayer3D = $Footstep
@onready var sprint_timer: Timer = $SprintTimer # Make sure this node exists!
@onready var camera_pivot: Node3D = $Head/CameraPivot
@onready var head: Node3D = $Head
@onready var portal: MeshInstance3D = $Portal
@onready var portal_sound: AudioStreamPlayer3D = $PortalSound
@onready var portal_anim: AnimationPlayer = $PortalAnim
@onready var camera_animation_player: AnimationPlayer = $CameraAnimationPlayer
@onready var player_animation_player: AnimationPlayer = $PlayerAnimationPlayer
@onready var mesh_animation_player: AnimationPlayer = $Mesh/AnimationPlayer
@onready var portal_animation_player: AnimationPlayer = $PortalAnimationPlayer
@onready var player_spawn: Marker3D = $"../Map/PlayerSpawn"
@onready var portal_timer: Timer = $PortalTimer

var camera_animation_playing := false
var health := 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.position = player_spawn.position
	# Configure the timer via code just in case
	sprint_timer.wait_time = 1.0
	sprint_timer.one_shot = true 
	# animate the camera
	camera_animation_playing = true
	portal_animation_player.play("portal_scale_up")
	portal_sound.play()
	player_animation_player.play("player_coming_from_portal")
	camera_animation_player.play("camera_spawn")
	await camera_animation_player.animation_finished
	camera_animation_playing = false

func _unhandled_input(event):
	if camera_animation_playing:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_x_rotation -= event.relative.y * MOUSE_SENSITIVITY
		camera_x_rotation = clamp(camera_x_rotation, deg_to_rad(-80), deg_to_rad(80))
		camera.rotation.x = camera_x_rotation

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not camera_animation_playing:
		velocity.y = JUMP_VELOCITY
		if not footstep.playing:
			footstep.pitch_scale = randf_range(0.8, 1.2)
			footstep.play()

	# Movement Logic
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction and not camera_animation_playing:
		# If moving and timer hasn't started yet, start it
		if sprint_timer.is_stopped() and SPEED == BASE_SPEED:
			sprint_timer.start()
		
		# play walking or running animation
		if SPEED == BASE_SPEED:
			mesh_animation_player.play("walking")
		else:
			mesh_animation_player.play("running")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		# Reset everything when player stops moving
		sprint_timer.stop()
		SPEED = BASE_SPEED
		mesh_animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Headbob logic
	if is_on_floor() and velocity.length() > 0.1:
		headbob_time += delta * velocity.length()
		camera.transform.origin = headbob(headbob_time)
	else:
		camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, delta * 10)
		headbob_time = 0.0

	# camera spin logic
	var camera_angle_to_spin_to := 0.0
	if Input.is_action_pressed("spin_camera") and not camera_animation_playing:
		camera_angle_to_spin_to = -180.0
	else:
		camera_angle_to_spin_to = 0.0
	
	head.rotation.y = lerp_angle(head.rotation.y, deg_to_rad(camera_angle_to_spin_to), 5 * delta)
	
	# death logic
	if health <= 0:
		queue_free()
	
func headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * headbob_frequency) * headbob_amplitude
	pos.x = cos(time * headbob_frequency / 2) * headbob_amplitude
	
	if sin(time * headbob_frequency) < -0.98:
		if not footstep.playing:
			footstep.pitch_scale = randf_range(0.8, 1.2)
			footstep.play()
	return pos

# This must be connected to the SprintTimer's timeout signal!
func _on_sprint_timer_timeout() -> void:
	SPEED = SPRINT_SPEED
	mesh_animation_player.queue("running")

func take_damage(damage):
	health -= damage
	print(health)

func _on_portal_timer_timeout() -> void:
	portal_animation_player.play_backwards("portal_scale_up")
	await portal_animation_player.animation_finished
	portal_sound.stop()
	portal.visible = false
