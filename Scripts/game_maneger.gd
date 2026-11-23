extends Node
# imports
@onready var hearts: HBoxContainer = $"../Hearts"
@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"../Player"

#consts
const FULL_HEART = 72
const EMPTY_HEART = 108

#vars
var health := 3
@onready var hearts_a = hearts.get_children()

#changing the hearts from full to empty
func change_hearts():
	for i in range(hearts_a.size()):
		var atlas = hearts_a[i].get_node("TextureRect").texture as AtlasTexture
		if i < health:
			atlas.region.position.x = FULL_HEART
		else:
			atlas.region.position.x = EMPTY_HEART

# taking damage
func _on_spikes_body_entered(body: Node2D) -> void:
	health -= 1
	health = clamp(health, 0, 3)
	change_hearts()
	if health <= 0:
		timer.start()
		Engine.time_scale = 0.5
		
		

# go to death screen
func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
	Engine.time_scale = 1
	

func _on_secret_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/secret_room.tscn")
