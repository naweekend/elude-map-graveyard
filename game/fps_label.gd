extends Label

var timer: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("devtools"):
		self.visible = !self.visible
	
	timer += 1 * delta
	if timer > 0.5: # Update twice per second
		text = "FPS: " + str(Engine.get_frames_per_second())
		timer = 0.0
