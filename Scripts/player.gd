extends CharacterBody2D

# constants
const SPEED = 120
const JUMP_VELOCITY = -500
const JUMP_H_SPEED = 200
const BOUNCE_DAMP = 0.55
const MIN_BOUNCE_SPEED = 20
const BUFFER_TIME: int = 500
const JUMP_VELOCITY2 = -300
const SPRINT_SPEED = 200
const DASH_SPEED = 450
const DASH_TIME = 0.15
const DASH_COOLDOWN = 2


# variables
var jump_charge = 0.0
var was_in_air: bool = false
var last_direction: float = 0.0
var last_direction_time: int = 0
var shake_intensity: float = 0.0
var is_stunned: bool = false
var double_jump: int = 1
var is_dashing: bool = false
var can_dash: bool = true


@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var camera: Camera2D = $Camera2D
@onready var movement_game_2: Node = $Movement_game_2



func _on_timer_timeout() -> void:
	is_stunned = false
	animations.play("Idle")
	
func _ready() -> void:
	if Global.use_custom_spawn:
		global_position = Global.spawn_position
		Global.use_custom_spawn = false
	movement_game_2.set_physics_process(false)
	
func enter_new_area() -> void:
	set_physics_process(false)
	movement_game_2.set_physics_process(true)

func exit_new_area() -> void:
	movement_game_2.set_physics_process(false)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction := Input.get_axis("left", "right")
	if get_tree().current_scene.scene_file_path == "res://Scenes/game.tscn" or get_tree().current_scene.scene_file_path == "res://Scenes/secret_room.tscn":
		# buffer
		if direction != 0:
			last_direction = direction
			last_direction_time = Time.get_ticks_msec()
	
		# charge jump
		if Input.is_action_pressed("ui_accept") and double_jump > 0 and not is_stunned:
			jump_charge += 0.7 * delta
			jump_charge = clamp(jump_charge, 0.1, 1.0)
			velocity.x = 0
			if animations.animation != "Jump_charge":
				animations.play("Jump_charge")
			shake_intensity = jump_charge * 0.6
			if not is_on_floor():
				velocity.x = 0
				velocity.y = 5
	
		elif Input.is_action_just_released("ui_accept") and double_jump > 0 and not is_stunned:
			var launch_dir = 0.0
			if direction != 0:
				launch_dir = direction
			elif Time.get_ticks_msec() - last_direction_time <= BUFFER_TIME:
				launch_dir = last_direction
			if launch_dir == 1:
				animations.flip_h = false
			elif launch_dir == -1:
				animations.flip_h = true
			animations.play("Jump_air")
			double_jump -= 1
			
			velocity.y = JUMP_VELOCITY * jump_charge
			velocity.x = jump_charge * JUMP_H_SPEED * launch_dir
			jump_charge = 0.0
			shake_intensity = 0.0
		
	
		#walking
		elif is_on_floor() and not is_stunned:
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			
			if abs(velocity.x) <= 1:
				animations.play("Idle")
			else:
				animations.play("Walking")
		
			if direction == 1:
				animations.flip_h = false
			elif direction == -1:
				animations.flip_h = true
			
		if not is_on_floor() and velocity.y >= 500:
			was_in_air = true
			animations.play("Jump_air")
	
		if is_on_floor() and was_in_air:
			is_stunned = true
			velocity.x = 0
			animations.play("Fall")
			timer.start()
			was_in_air = false
	
		if is_on_floor():
			double_jump = 1
	
	# camera shak
	#if shake_intensity > 0.0:
		#camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		#shake_intensity = lerp(shake_intensity, 0.0, delta * 2.0)
	#else:
		#camera.offset = Vector2.ZERO
	
	
	
		# bounce
		var pre_velocity := velocity
		move_and_slide()
	
		if not is_on_floor() and is_on_wall() and abs(pre_velocity.x) > MIN_BOUNCE_SPEED:
			var normal := get_wall_normal()
			velocity.x = normal.x * abs(pre_velocity.x) * BOUNCE_DAMP
			velocity.y = pre_velocity.y
			animations.flip_h = velocity.x < 0
	
	
	# zooming
	if Input.is_action_just_pressed("zoom in"):
		if camera.zoom.x <= 5:
			camera.zoom.x += 1
			camera.zoom.y += 1
	if Input.is_action_just_pressed("zoom out"):
		if camera.zoom.x > 1:
			camera.zoom.x -= 1
			camera.zoom.y -= 1
