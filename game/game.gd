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

func _ready() -> void:	
	# get a random value
	var density = randf_range(0.005, 0.01)
	var colors = fog_colors.pick_random()
	var albedo = Color(colors["albedo"])
	var emission = Color(colors["emission"])
	var env = world_environment.environment
	env.volumetric_fog_density = density
	env.volumetric_fog_albedo = albedo
	env.volumetric_fog_emission = emission
