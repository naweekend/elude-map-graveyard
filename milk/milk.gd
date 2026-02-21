extends Area3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh: Node3D = $Mesh
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var milk_captured: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" and body is CharacterBody3D:
		milk_captured += 1
		mesh.visible = false
		audio_stream_player_3d.play()
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(0.5).timeout
		queue_free()
