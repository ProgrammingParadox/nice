extends CharacterBody2D

var is_dash_candidate := false
var is_dead := false


func _process(delta: float) -> void:
	if is_dash_candidate and not is_dead:
		modulate = Color(0.0, 255.0, 0.0)
	elif is_dead:
		modulate = Color(0.0, 0.0, 255.0)
	else:
		modulate = Color(255.0, 0.0, 0.0)


func _physics_process(delta: float) -> void:
	pass
