extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	
	if Input.get_axis("left", "right") != 0 and player.velocity.y > 0.0:
		player.velocity.y = min(player.velocity.y, stats.MAX_WALL_CLING_SPEED)
	else:
		finished.emit(AIRBORNE)
	
	player.move_and_slide()

	if player.is_on_floor():
		finished.emit(GROUNDED)
