extends Node
# imports
@onready var hearts: HBoxContainer = $"../Hearts"
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"../Player"
@onready var animation_player: AnimationPlayer = $"../../AnimatableBody2D/AnimationPlayer"

#consts
const FULL_HEART = 72
const EMPTY_HEART = 108

#vars
var health := 3
var aniamtion_played = false
@onready var hearts_a = hearts.get_children()

#changing the hearts from full to empty
func change_hearts():
	for i in range(hearts_a.size()):
		var atlas = hearts_a[i].get_node("TextureRect").texture as AtlasTexture
		if i < health:
			atlas.region.position.x = FULL_HEART
		else:
			atlas.region.position.x = EMPTY_HEART

func take_damage():
	health -= 1
	health = clamp(health, 0, 3)
	change_hearts()
	if health <= 0:
		timer.start()
		Engine.time_scale = 0.5
	
# taking damage
func _on_spikes_body_entered(body: Node2D) -> void:
	take_damage()
		
		

# go to death screen
func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
	Engine.time_scale = 1
	

func _on_secret_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/secret_room.tscn")

func _on_spike_5_body_entered(body: Node2D) -> void:
	take_damage()

func _on_spike_6_body_entered(body: Node2D) -> void:
	take_damage()

func _on_spike_4_body_entered(body: Node2D) -> void:
	take_damage()

func _on_spike_3_body_entered(body: Node2D) -> void:
	take_damage()

func _on_spike_2_body_entered(body: Node2D) -> void:
	take_damage()

func _on_spike_body_entered(body: Node2D) -> void:
	take_damage()

func _on_lever_body_entered(body: Node2D) -> void:
	if aniamtion_played == false:
		animation_player.play("Moving Roof")
		aniamtion_played = true


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("entered")
		Global.spawn_position = Vector2(-104.0, -1336.0)
		Global.use_custom_spawn = true
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")
