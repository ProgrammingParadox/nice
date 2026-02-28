extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = stats.JUMP_VELOCITY
	finished.emit(AIRBORNE)

func physics_update(delta: float) -> void:
	pass
