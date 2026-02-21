extends DirectionalLight3D

# Change this to make the day faster or slower
@export var day_duration_seconds: float = 120

func _process(delta):
	# Calculate how much to rotate based on time
	var rotation_speed = (PI * 2) / day_duration_seconds
	rotate_x(rotation_speed * delta)
