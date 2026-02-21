extends CharacterBody3D

@export var SPEED: float = randf_range(9, 13)
@export var JUMP_VELOCITY: float = 10.0
@export var JUMP_DISTANCE: float = 5.0

@onready var player: CharacterBody3D = $"../../Player"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var audio_player: AudioStreamPlayer3D = $Audio
@onready var audio_timer: Timer = $AudioTimer
@onready var area_3d: Area3D = $Area3D

const AYAN_MOB: MobData = preload("uid://brobkrnjqm5sp")
const GIGACHAD_MOB = preload("uid://c3jo2jfss5ym4")
var mobs: Array[MobData] = [AYAN_MOB, GIGACHAD_MOB]
var offset_mob: bool = false
var is_touching_player := false

func _ready() -> void:
	# assign the mob data to nodes
	var mob = mobs.pick_random()
	self.name = "Mob" + mob.mob_name
	sprite_3d.texture = mob.mob_pic
	audio_player.stream = mob.mob_sound
	audio_timer.wait_time = mob.sound_time
	audio_timer.start()
	# flip 50% of the time
	var flip_chance = randi_range(0, 1)
	if flip_chance == 0:
		sprite_3d.flip_h = true
	# offset chance
	var offset_chance = randi_range(0, 2)
	print(offset_chance)
	if offset_chance == 0:
		offset_mob = true
	else:
		offset_mob = false

func _physics_process(delta: float) -> void:
	# 1. Always apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Set the target
	nav_agent.target_position = player.global_position
	
	var next_pos: Vector3
	
	# 3. Check if the path is reachable
	if nav_agent.is_target_reachable():
		# Follow the NavMesh path
		next_pos = nav_agent.get_next_path_position()
	else:
		# FALLBACK: Move directly toward the player's X/Z 
		# This allows the mob to "rub" against the wall so it can jump
		next_pos = player.global_position

	# 4. Horizontal Movement
	var horizontal_dist = Vector2(global_position.x, global_position.z).distance_to(Vector2(player.global_position.x, player.global_position.z))
	
	if not offset_mob:
		var dir = (next_pos - global_position).normalized()
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
	else:
		# if it is an offset mob, check horizontal distance
		if horizontal_dist > 60:
			var dir = (next_pos + (Vector3(40, 0, 40) * transform.basis) - global_position).normalized()
			velocity.x = dir.x * SPEED
			velocity.z = dir.z * SPEED
		else:
			var dir = (next_pos - global_position).normalized()
			velocity.x = dir.x * SPEED
			velocity.z = dir.z * SPEED
			
	# 5. Jump Logic (Vertical Gap detection)
	# Check if the player is significantly higher than the mob
	var height_diff = player.global_position.y - self.global_position.y
	
	if height_diff > 0.5 and self.is_on_floor() and player.is_on_floor():
		# Only jump if we are close enough to the wall/player
		if horizontal_dist < JUMP_DISTANCE: # Adjust this 'reach' distance as needed
			velocity.y = JUMP_VELOCITY
			print("Jumping to reach player")

	# 6. Make the mob face towards the player
	# Only rotate if the mob is actually moving/trying to move
	if velocity.length() > 0.1:
		var look_target = player.global_position
		# This is the "secret sauce": 
		# Force the target's height to match the mob's height 
		# so it doesn't tilt up or down.
		look_target.y = self.global_position.y 
		# Now look at that adjusted point
		look_at(look_target, Vector3.UP)
		
	move_and_slide()
	
	# damage player
	if is_touching_player:
			var dmg = randi_range(5, 20)
			player.take_damage(dmg * delta)


func _on_audio_timer_timeout() -> void:
	$Audio.play()
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" and body is CharacterBody3D:
		is_touching_player = true
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player" and body is CharacterBody3D:
		is_touching_player = false
