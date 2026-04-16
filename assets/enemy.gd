extends CharacterBody2D

var is_dash_candidate := false
var is_dead := false


func _process(delta: float) -> void:
	if is_dash_candidate and not is_dead:
		set_modulate(Color(0.7, 1.5, 0.7))
	elif is_dead:
		set_modulate(Color(0.3, 0.3, 0.3))
	else:
		set_modulate(Color(1.0, 1.0, 1.0))

	if Input.is_action_just_pressed("debug_reset"):
		is_dead = false


func _physics_process(delta: float) -> void:
	pass
