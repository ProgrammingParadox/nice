extends PlayerState

var path: Array[Vector2]


func enter(previous_state_path: String, data := { }) -> void:
	#player.velocity.y = stats.JUMP_VELOCITY

	context.jumps = 1

	var closest_ref = player.find_dash_candidate()

	# no enemies, or a bug :/
	if closest_ref == null:
		print("no closest_ref", player.position)
		finished.emit(AIRBORNE)
		return

	if data.has("path"):
		path = data.path

	#closest_ref.is_dash_candidate = true

	#var direction: Vector2 = (closest_ref.position - player.position).normalized()

	# velocity-based dash
	#context.dash_vel = direction * stats.DASH_VELOCITY

	#finished.emit(AIRBORNE)

	# Dashing-state based
	player.velocity = Vector2.ZERO
	finished.emit(
		DASHING,
		{
			"position": closest_ref.position,
			"reference": closest_ref,
			"path": path,
		},
	)


func physics_update(delta: float) -> void:
	pass
