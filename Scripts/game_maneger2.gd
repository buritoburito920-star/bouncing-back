extends Node


func _on_falling_death_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
