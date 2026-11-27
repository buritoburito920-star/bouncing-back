extends Node2D
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	player.enter_new_area()
