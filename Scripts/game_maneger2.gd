extends Node
@onready var label_7: Label = $"../Labels/Label7"


func _on_falling_death_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
func _process(delta: float) -> void:
	if "1" in Global.collected_coin:
		label_7.visible = true
