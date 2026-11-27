extends Node
@onready var player: CharacterBody2D = $".."
@onready var buffer_timer_2: Timer = $"../buffer_Timer2"
@onready var float_timer: Timer = $"../float_timer"
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var ledgespace: RayCast2D = %ledgespace
@onready var ledge_climber: RayCast2D = %ledge_climber
@onready var double_jump_animation_timer: Timer = $"../double_jump_animation_timer"
@onready var animations: Timer = $"../animations"
@onready var wall_slide: RayCast2D = %Wall_slide
@onready var dash_cool: Timer = $"../Dash_cool"
@onready var camera: Camera2D = $"../Camera2D"
#@onready var attack: AnimatedSprite2D = $"../Attack"


enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	FLOAT,
	LEDGE_CLIMB,
	LEDGE_JUMP,
	WALL_SLIDE,
	WALL_JUMP,
	WALL_CLIMB,
	DASH,
	TURNING,
}
var active_state := STATE.FALL
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
var can_double_jump := false
var facing_direction = 1
var saved_position := Vector2.ZERO
var can_dash := false
var dash_jump_buffer := false
var is_sprinting := false

const FALL_GRAVITY := 1100
const FALL_VELOCITY := 500
const WALK_VELOCITY := 120
const JUMP_VELOCITY := -500
const JUMP_DECCELERATION := 1500
const DOUBLE_JUMP_VELOCITY := -450
const FLOAT_GRAVITY := 200
const FLOAT_VELOCITY := 100
const LEDGE_JUMP_VELOCITY := -100
const WALL_SLIDE_GRAVITY := 300
const WALL_SLIDE_VELOCITY := 500
const WALL_JUMP_LENG := 30
const WALL_JUMP_VELOCITY := -500
const WALL_CLIMB_VELOCITY := -300
const WALL_CLIMB_LENG := 40
const DASH_LENG := 100
const DASH_VELOCITY := 600
const SPRINT_VELOCITY := 250
const SPRINT_ACCEL := 1200
const FLOAT_ACCEL := 700


func _ready() -> void:
	switch_state(active_state)
	ledge_climber.add_exception(player)
	#attack.visible = false
	
	

func _physics_process(delta: float) -> void:
	process_state(delta)
	player.move_and_slide()
	
func switch_state(to_state: STATE) -> void:
	var previous_state := active_state 
	active_state = to_state
	
	match active_state:
		STATE.FALL:
			if previous_state != STATE.DOUBLE_JUMP:
				animated_sprite_2d.play("Jump_air")
			if previous_state == STATE.FLOOR:
				buffer_timer_2.start()
			
		STATE.FLOOR:
			can_double_jump = true
			can_dash = true
		
		STATE.JUMP:
			if previous_state != STATE.TURNING: 
				animated_sprite_2d.play("Jumping")
			player.velocity.y = JUMP_VELOCITY
			buffer_timer_2.stop()
		
		STATE.DOUBLE_JUMP:
			animated_sprite_2d.play("Double_jump") 
			player.velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
			is_sprinting = false
			
		STATE.FLOAT:
			if float_timer.time_left > 0:
				active_state = previous_state
				return
			animated_sprite_2d.play("Float")
			player.velocity.y = 0
			is_sprinting = false
		
		STATE.LEDGE_CLIMB:
			animated_sprite_2d.play("LedgeClimb")
			player.velocity = Vector2.ZERO
			
			player.global_position.y = ledge_climber.get_collision_point().y
			can_double_jump = true
		
		STATE.LEDGE_JUMP:
			animated_sprite_2d.play("Double_jump")
			player.velocity.y = LEDGE_JUMP_VELOCITY
			can_dash = true
			is_sprinting = false
			
		STATE.WALL_SLIDE:
			animated_sprite_2d.play("Wall_slide") # need wall slide animaiton
			player.velocity.y = 0
			can_double_jump = true
			can_dash = true
			is_sprinting = false
			
			
		STATE.WALL_JUMP:
			animated_sprite_2d.play("Jumping")
			player.velocity.y = WALL_JUMP_VELOCITY
			set_facing_direction(-facing_direction)
			saved_position = player.position
			
			
		STATE.WALL_CLIMB:
			animated_sprite_2d.play("Double_jump") # need wall_climb aniamtion
			player.velocity.y = WALL_CLIMB_VELOCITY
			saved_position = player.position
			
		STATE.DASH:
			if dash_cool.time_left > 0:
				active_state = previous_state
				return
			animated_sprite_2d.play("Dash") # need dash animation
			player.velocity.y = 0
			set_facing_direction(signf(Input.get_axis("left", "right")))
			player.velocity.x = DASH_VELOCITY * facing_direction
			saved_position = player.position
			can_dash = previous_state == STATE.FLOOR or previous_state == STATE.WALL_SLIDE
			dash_jump_buffer = false
			
		STATE.TURNING:
			set_facing_direction(-facing_direction)
		
func process_state(delta: float) -> void:
	match active_state:
		STATE.FALL:
			player.velocity.y = move_toward(player.velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
			if is_sprinting and player.is_on_floor():
				handle_sprint(delta)
			else:
				handle_movement()
			
			if player.is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("ui_accept"):
				if buffer_timer_2.time_left > 0:
					switch_state(STATE.JUMP)
				elif can_double_jump:
					switch_state(STATE.DOUBLE_JUMP)
				else:
					switch_state(STATE.FLOAT)
					
			elif is_input_toward_facing() and is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
				
			elif is_input_toward_facing() and can_wall_slide():
				switch_state(STATE.WALL_SLIDE)
			elif Input.is_action_just_pressed("Sprinting") and can_dash:
				switch_state(STATE.DASH)
				
				
		STATE.FLOOR:
			if is_sprinting and player.is_on_floor():
				animated_sprite_2d.play("Running")
				handle_sprint(delta)
			else:
				if Input.get_axis("left", "right"):
					animated_sprite_2d.play("Walking")
				else:
					animated_sprite_2d.play("Idle")
				handle_movement()
		
			if not player.is_on_floor():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("ui_accept"):
				switch_state(STATE.JUMP)
			elif Input.is_action_just_pressed("Sprinting"):
				switch_state(STATE.DASH)
			elif is_sprinting and is_input_against_facing():
				switch_state(STATE.TURNING)
				
		STATE.JUMP, STATE.DOUBLE_JUMP, STATE.LEDGE_JUMP, STATE.WALL_JUMP:
			player.velocity.y = move_toward(player.velocity.y, 0, JUMP_DECCELERATION * delta)
			if active_state == STATE.WALL_JUMP:
				var distance = abs(player.position.x - saved_position.x)
				if distance >= WALL_JUMP_LENG or can_wall_slide():
					switch_state(STATE.JUMP)
				else:
					handle_movement(facing_direction)
					
					
			if is_sprinting and player.is_on_floor():
				handle_sprint(delta)
			elif active_state != STATE.WALL_JUMP:
				handle_movement()
			
			if Input.is_action_just_released("ui_accept") or player.velocity.y >= 0:
				player.velocity.y = 0
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("ui_accept"):
				switch_state(STATE.DOUBLE_JUMP)
			elif Input.is_action_just_pressed("Sprinting") and can_dash:
				switch_state(STATE.DASH)
			match active_state:
				STATE.DOUBLE_JUMP:
					double_jump_animation_timer.start()
				
		STATE.FLOAT:
			player.velocity.y = move_toward(player.velocity.y, FLOAT_VELOCITY, FLOAT_GRAVITY * delta)
			handle_movement(0, WALK_VELOCITY, FLOAT_ACCEL * delta)
			
			if player.is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_released("ui_accept"):
				float_timer.start()
				switch_state(STATE.FALL)
			elif is_input_toward_facing() and is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
			elif is_input_toward_facing() and can_wall_slide():
				switch_state(STATE.WALL_SLIDE)
			elif Input.is_action_just_pressed("Sprinting") and can_dash:
				switch_state(STATE.DASH)
				
		STATE.LEDGE_CLIMB:
			is_sprinting = Input.is_action_pressed("Sprinting")
			if not animated_sprite_2d.is_playing():
				animated_sprite_2d.play("LedgeClimb")
				var offset := ledge_climb_offset()
				offset.x *= facing_direction
				player.position += offset
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("ui_accept"):
				var progress := inverse_lerp(0, animated_sprite_2d.sprite_frames.get_frame_count("Jumping"), animated_sprite_2d.frame)
				var offset := ledge_climb_offset()
				offset.x *= facing_direction * progress
				player.position += offset
				switch_state(STATE.JUMP)
				
		STATE.WALL_SLIDE:
			player.velocity.y = move_toward(player.velocity.y, WALL_SLIDE_VELOCITY, WALL_SLIDE_GRAVITY * delta)
			handle_movement()
			
			if player.is_on_floor():
				switch_state(STATE.FLOOR)
			elif is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
			elif not can_wall_slide():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("ui_accept"):
				switch_state(STATE.WALL_JUMP)
			elif Input.is_action_just_pressed("Sprinting"):
				if is_input_toward_facing():
					switch_state(STATE.WALL_CLIMB)
				else:
					set_facing_direction(-facing_direction)
					switch_state(STATE.DASH)
				
		STATE.WALL_CLIMB:
			var distance = abs(player.position.y - saved_position.y)
			if distance >= WALL_CLIMB_LENG or player.is_on_ceiling():
				player.velocity.y = 0
				switch_state(STATE.WALL_SLIDE)
			elif is_ledge():
				switch_state(STATE.LEDGE_JUMP)
				
				
		STATE.DASH:
			is_sprinting = Input.is_action_pressed("Sprinting")
			dash_cool.start()
			if player.is_on_floor():
				buffer_timer_2.start()
			if Input.is_action_just_pressed("ui_accept"):
				dash_jump_buffer = true
			var distance := absf(player.position.x - saved_position.x)
			if distance >= DASH_LENG or signf(player.get_last_motion().x) != facing_direction:
				if dash_jump_buffer and buffer_timer_2.time_left > 0:
					switch_state(STATE.JUMP)
				elif player.is_on_floor():
					switch_state(STATE.FLOOR)
				else:
					switch_state(STATE.FALL)
			elif is_ledge() and is_space():
				switch_state(STATE.LEDGE_CLIMB)
			elif can_wall_slide():
				switch_state(STATE.WALL_SLIDE)
				
				
				
				
		STATE.TURNING:
			if signf(player.velocity.x) == facing_direction and is_input_against_facing():
				set_facing_direction(-facing_direction)
			handle_movement()
			
			if not player.is_on_floor():
				switch_state(STATE.FALL)
			elif not Input.is_action_pressed("Sprinting") or player.velocity.x * facing_direction >= SPRINT_VELOCITY:
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("ui_accept"):
				animated_sprite_2d.play("Double_jump")
				is_sprinting = false
				switch_state(STATE.JUMP)
				
	if Input.is_action_just_pressed("zoom in"):
		if camera.zoom.x <= 5:
			camera.zoom.x += 1
			camera.zoom.y += 1
	if Input.is_action_just_pressed("zoom out"):
		if camera.zoom.x > 1:
			camera.zoom.x -= 1
			camera.zoom.y -= 1
			
func handle_movement(input_direction: float = 0, horizontal_velocity: float = WALK_VELOCITY, step: float = WALK_VELOCITY) -> void:
	if input_direction == 0:
		input_direction = signf(Input.get_axis("left", "right"))
	set_facing_direction(input_direction)
	player.velocity.x = move_toward(player.velocity.x, input_direction * horizontal_velocity, step)
	

func handle_sprint(delta: float) -> void:
	handle_movement(facing_direction, SPRINT_VELOCITY, SPRINT_ACCEL * delta)
	is_sprinting = Input.is_action_pressed("Sprinting")
	
func set_facing_direction(direction: float) -> void:
	if direction:
		animated_sprite_2d.flip_h = direction < 0
		facing_direction = direction
		ledge_climber.position.x = direction * abs(ledge_climber.position.x)
		ledge_climber.target_position.x = direction * abs(ledge_climber.target_position.x)
		ledge_climber.force_raycast_update()
		wall_slide.position.x = direction * abs(wall_slide.position.x)
		wall_slide.target_position.x = direction * abs(wall_slide.target_position.x)
		wall_slide.force_raycast_update()
	
	
func is_input_toward_facing() -> bool:
	return signf(Input.get_axis("left", "right")) == facing_direction
	
func is_input_against_facing() -> bool:
	return signf(Input.get_axis("left", "right")) == -facing_direction
	
	
func is_ledge() -> bool:
	return not player.is_on_floor() and \
	player.is_on_wall_only() and \
	ledge_climber.is_colliding() and \
	ledge_climber.get_collision_normal().is_equal_approx(Vector2.UP)
	
func is_space() -> bool:
	ledgespace.global_position = ledge_climber.get_collision_point()
	ledgespace.force_raycast_update()
	return not ledgespace.is_colliding()
	
	
func ledge_climb_offset() -> Vector2:
	var shape := collision_shape_2d.shape
	if shape is RectangleShape2D:
		return Vector2(shape.size.x, -shape.size.y * 0.5)
	return Vector2.ZERO


func _on_double_jump_animation_timer_timeout() -> void:
	animated_sprite_2d.play("Jump_air")






func can_wall_slide() -> bool:
	return player.is_on_wall_only() and wall_slide.is_colliding()
