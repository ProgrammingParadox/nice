extends CharacterBody2D

var is_dash_candidate := false


func _process(delta: float) -> void:
	if is_dash_candidate:
		modulate = Color(0.0, 255.0, 0.0)
	else:
		modulate = Color(255.0, 0.0, 0.0)


func _physics_process(delta: float) -> void:
	pass
