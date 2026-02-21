extends Node3D

@export var mob_tscn: PackedScene
@export var spawn_interval: float = 1.0
@export_range(0, 99, 1) var mob_count: int = 10
var current_mob_count: int = 0

func _ready() -> void:
	$Timer.wait_time = spawn_interval

func _on_timer_timeout() -> void:
	if current_mob_count < mob_count:
		var mob: CharacterBody3D = mob_tscn.instantiate()
		self.add_child(mob)
		mob.name = "Mob"
		mob.global_position = $Marker3D.global_position
		current_mob_count += 1
