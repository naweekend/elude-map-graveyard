extends Node3D


@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var portal: MeshInstance3D = $Portal
@onready var portal_sound: AudioStreamPlayer3D = $PortalSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_animation_player: AnimationPlayer = $PlayerMesh/AnimationPlayer
@onready var player_mesh: Node3D = $PlayerMesh
@onready var player_fall_timer: Timer = $PlayerFallTimer
@onready var play_button: TextureButton = $CanvasLayer/PlayButton
@onready var portal_animation_player: AnimationPlayer = $PortalAnimationPlayer


var fog_colors = [
	{"albedo": "#FF1493", "emission": "#4B0082"}, # Neon Pink / Deep Indigo
	{"albedo": "#00FF7F", "emission": "#004020"}, # Radioactive Green / Dark Forest
	{"albedo": "#9B30FF", "emission": "#2A0052"}, # Electric Purple / Void
	{"albedo": "#FF4500", "emission": "#420F00"}, # Blood Orange / Burnt Ember
	{"albedo": "#00E5FF", "emission": "#002B30"}, # Cyber Cyan / Deep Ocean
	{"albedo": "#FF00FF", "emission": "#330033"}, # Hot Magenta / Nightshade
	{"albedo": "#F0E68C", "emission": "#4D4D00"}  # Sulfur Yellow / Dark Olive
]
var falling_down := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_animation_player.play("idle")
	portal.scale = Vector3(0, 0, 0)
	# get a random value (world env)
	var density = randf_range(0.005, 0.01)
	var colors = fog_colors.pick_random()
	var albedo = Color(colors["albedo"])
	var emission = Color(colors["emission"])
	var env = world_environment.environment
	env.volumetric_fog_density = density
	env.volumetric_fog_albedo = albedo
	env.volumetric_fog_emission = emission
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if falling_down:
		player_mesh.transform.origin.y -= 3 * delta


func _on_play_button_pressed() -> void:
	# when play button is pressed
	animation_player.play("portal_scale_up")
	portal_sound.play()
	portal.scale = Vector3(1, 1, 1)
	player_animation_player.play("look_down_portal")
	# start the player fall timer, wait for 1.5 seconds then make the player fall
	player_fall_timer.start()
	play_button.disabled = true

func _on_player_fall_timer_timeout() -> void:
	falling_down = true
	animation_player.play("color_rect_fade_in")
	print(get_tree())
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "color_rect_fade_in":
		get_tree().change_scene_to_file("res://game/game.tscn")
	

func _on_exit_button_pressed() -> void:
	get_tree().quit()
