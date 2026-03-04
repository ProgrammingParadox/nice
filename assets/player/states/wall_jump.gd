extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	player.velocity.y = stats.WALL_JUMP_VERTICAL_VELOCITY
	player.velocity.x = stats.WALL_JUMP_HORIZONTAL_VELOCITY * data.direction

	context.jumps = 0
	context.time_since_last_jump_pressed = INF

	finished.emit(AIRBORNE)


func physics_update(delta: float) -> void:
	pass
