extends Node3D

@onready var world_environment: WorldEnvironment = $WorldEnvironment
var fog_colors = [
	{"albedo": "#FF1493", "emission": "#4B0082"}, # Neon Pink / Deep Indigo
	{"albedo": "#00FF7F", "emission": "#004020"}, # Radioactive Green / Dark Forest
	{"albedo": "#9B30FF", "emission": "#2A0052"}, # Electric Purple / Void
	{"albedo": "#FF4500", "emission": "#420F00"}, # Blood Orange / Burnt Ember
	{"albedo": "#00E5FF", "emission": "#002B30"}, # Cyber Cyan / Deep Ocean
	{"albedo": "#FF00FF", "emission": "#330033"}, # Hot Magenta / Nightshade
	{"albedo": "#F0E68C", "emission": "#4D4D00"}  # Sulfur Yellow / Dark Olive
]
var game_modes = ["easy", "normal", "hard"]
@onready var mob_spawner: Node3D = $MobSpawner
@onready var mob_spawner_2: Node3D = $MobSpawner2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var time_progress_bar: ProgressBar = $CanvasLayer/TimeProgressBar
@onready var round_timer: Timer = $RoundTimer
@onready var time_label: Label = $CanvasLayer/TimeLabel

func _ready() -> void:		
	# get a random value
	#var density = randf_range(0.005, 0.01)
	#var colors = fog_colors.pick_random()
	#var albedo = Color(colors["albedo"])
	#var emission = Color(colors["emission"])
	#var env = world_environment.environment
	#env.volumetric_fog_density = density
	#env.volumetric_fog_albedo = albedo
	#env.volumetric_fog_emission = emission
	
	# fade out the color rect
	animation_player.play("color_rect_fadeout")
	await animation_player.animation_finished
	color_rect.color = Color(00000000)
	
	var game_mode = game_modes.pick_random()
	print(game_mode)
	if game_mode == "easy":
		mob_spawner.mob_count = 0
		mob_spawner_2.mob_count = 0
	elif game_mode == "normal":
		mob_spawner.mob_count = 2
		mob_spawner.spawn_interval = 30
		mob_spawner_2.mob_count = 1	
		mob_spawner_2.spawn_interval = 60
	elif game_mode == "hard":
		mob_spawner.mob_count = 2
		mob_spawner.spawn_interval = 30
		mob_spawner_2.mob_count = 3
		mob_spawner_2.spawn_interval = 30
		
func _process(delta: float) -> void:
	# round timer and time progress bar
	time_progress_bar.value = round_timer.time_left
	# Update the label with the formatted string
	time_label.text = format_time(round_timer.time_left)

func _on_round_timer_timeout() -> void:
	# if the timer times out, means the player did not switch to win screen, means they didnt win so switch to lose screen
	get_tree().change_scene_to_file("res://game/game.tscn")

func format_time(time_in_seconds: float) -> String:
	var minutes: int = int(time_in_seconds) / 60
	var seconds: int = int(time_in_seconds) % 60
	
	return "%02d:%02d" % [minutes, seconds]
