extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	player.velocity.y = stats.JUMP_VELOCITY
	context.jumps += 1
	finished.emit(AIRBORNE)


func physics_update(delta: float) -> void:
	pass
