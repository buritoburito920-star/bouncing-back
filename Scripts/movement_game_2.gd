extends Node
@onready var player: CharacterBody2D = $".."
@onready var buffer_timer_2: Timer = $"../buffer_Timer2"


enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	FLOAT,
	LEDGE_CLIMB,
	LEDGE_JUMP
}
var active_state := STATE.FALL
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

const FALL_GRAVITY := 1500
const FALL_VELOCITY := 500
const WALK_VELOCITY := 200
const JUMP_VELOCITY := -600
const JUMP_DECCELERATION := 1500


func _ready() -> void:
	switch_state(active_state)

func _physics_process(delta: float) -> void:
	process_state(delta)
	player.move_and_slide()
	
func switch_state(to_state: STATE) -> void:
	var previous_state := active_state 
	active_state = to_state
	
	match active_state:
		STATE.FALL:
			animated_sprite_2d.play("Jump_air")
			if previous_state == STATE.FLOOR:
				buffer_timer_2.start()
			
		STATE.JUMP:
			animated_sprite_2d.play("Jumping")
			player.velocity.y = JUMP_VELOCITY
			buffer_timer_2.stop()

func process_state(delta: float) -> void:
	match active_state:
		STATE.FALL:
			player.velocity.y = move_toward(player.velocity.y, FALL_VELOCITY, FALL_GRAVITY * delta)
			handle_movement()
			
			if player.is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("ui_accept") and buffer_timer_2.time_left > 0:
				switch_state(STATE.JUMP)
			
		STATE.FLOOR:
			if Input.get_axis("left", "right"):
				animated_sprite_2d.play("Walking")
			else:
				animated_sprite_2d.play("Idle")
			handle_movement()
		
			if not player.is_on_floor():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("ui_accept"):
				switch_state(STATE.JUMP)
				
		STATE.JUMP:
			player.velocity.y = move_toward(player.velocity.y, 0, JUMP_DECCELERATION * delta)
			handle_movement()
			
			if Input.is_action_just_released("ui_accept") or player.velocity.y >= 0:
				player.velocity.y = 0
				switch_state(STATE.FALL)

func handle_movement() -> void:
	var direction := signf(Input.get_axis("left", "right"))
	if direction:
		animated_sprite_2d.flip_h = direction < 0
	player.velocity.x = WALK_VELOCITY * direction
