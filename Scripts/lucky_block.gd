extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var Used_texture: Texture2D
@export var Lucky_Block_ID: String = ""

var is_used := false
const coin_scene = preload("res://Scenes/coin.tscn")

func set_used_visual() -> void:
	if Used_texture != null:
		sprite_2d.texture = Used_texture

func _ready() -> void:
	if Lucky_Block_ID == "":
		Lucky_Block_ID = str(global_position)
	if Lucky_Block_ID in Global.collected_coin:
		is_used = true


func _on_lucky_block_touch_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_used:
		is_used = true
		Global.collected_coin.append(Lucky_Block_ID)
		var new_coin = coin_scene.instantiate()
		new_coin.global_position = global_position + Vector2(0, -18)
		get_tree().current_scene.call_deferred("add_child", new_coin)
		set_used_visual()

	
