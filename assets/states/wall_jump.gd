extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y = stats.JUMP_VELOCITY
	player.velocity.x = stats.WALL_JUMP_VELOCITY * data.direction;
	
	finished.emit(AIRBORNE)

func physics_update(delta: float) -> void:
	pass
