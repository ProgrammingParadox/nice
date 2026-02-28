extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = stats.JUMP_VELOCITY

func physics_update(delta: float) -> void:
	finished.emit(AIRBORNE)
