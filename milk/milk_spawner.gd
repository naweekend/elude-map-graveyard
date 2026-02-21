extends Node3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
const milk_tscn = preload("uid://dfjyjra0rg56w")
var milks_count = 0

func _physics_process(delta: float) -> void:
	while milks_count < 5:
		var random_pos: Dictionary = {
			"x": 0,
			"y": 0,
			"z": 0
		}
		random_pos["x"] = randf_range(-350, 350)
		random_pos["y"] = randf_range(0, 10)
		random_pos["z"] = randf_range(-350, 350)
		var target_pos = Vector3(random_pos["x"], random_pos["y"], random_pos["z"])
		nav_agent.target_position = target_pos
		
		if nav_agent.is_target_reachable():
			var milk: Area3D = milk_tscn.instantiate()
			milk.global_position = target_pos
			self.add_child(milk)
			milks_count += 1
		else:
			continue
		
	
