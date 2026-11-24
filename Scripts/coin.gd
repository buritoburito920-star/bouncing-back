extends Node2D

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 12, 0.15)
	tween.tween_property(self, "position:y", position.y, 0.15)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		queue_free()
