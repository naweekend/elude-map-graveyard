extends Node3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var milk_label: Label = $"../CanvasLayer/HBoxContainer/MilkLabel"
const milk_tscn = preload("uid://dfjyjra0rg56w")
var milks_count = 0
@export var total_milks: int = 5
@export var milks_captured: int = 0

func _physics_process(delta: float) -> void:
	while milks_count < total_milks:
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
		
	
	milk_label.text = str(milks_captured) + " / " + str(total_milks)
	
	# if all milks collected
	if milks_captured == total_milks:
		get_tree().change_scene_to_file("res://game/game.tscn")
	
