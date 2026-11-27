extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy: CollisionShape2D = $AnimatedSprite2D/Enemy_ptp/Enemy

var direction = 1

const SPEED := 60
const POSITION_LIMIT_R := 50
const POSITION_LIMIT_L := -50


func _process(delta: float) -> void:
	animated_sprite_2d.position.x += SPEED * direction * delta
	animated_sprite_2d.play("Walk")
	if animated_sprite_2d.position.x >= POSITION_LIMIT_R:
		animated_sprite_2d.flip_h = true
		direction = -1
	if animated_sprite_2d.position.x <= POSITION_LIMIT_L:
		animated_sprite_2d.flip_h = false
		direction = 1


func _on_enemy_ptp_body_entered(body: Node2D) -> void:
	if body.name == "Test":
		queue_free()
