extends Area3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh: Node3D = $Mesh
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and body is CharacterBody3D:
		var spawner = get_tree().root.get_node("Game/MilkSpawner")
		spawner.milks_captured += 1
		mesh.visible = false
		audio_stream_player_3d.play()
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(0.5).timeout
		queue_free()
