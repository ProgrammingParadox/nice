extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func lerp(v0: float, v1: float, t: float):
	return (1 - t) * v0 + t * v1


func lerp_v(v0: Vector2, v1: Vector2, t: float) -> Vector2:
	return Vector2(
		lerp(v0.x, v1.x, t),
		lerp(v0.y, v1.y, t),
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()

	$Camera2D.global_position = lerp_v($Camera2D.global_position, $Player.global_position, 0.1)
