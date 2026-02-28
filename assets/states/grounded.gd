extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	if context.time_since_jump_pressed < 0.1:
		finished.emit(JUMP)

func physics_update(delta: float) -> void:
	super(delta)
	
	var direction := Input.get_axis("left", "right")
	player.velocity.x += stats.ACCELERATION * direction * delta * 20
	
	player.velocity.x = clamp(player.velocity.x, -stats.MAX_SPEED, stats.MAX_SPEED)
	player.velocity.x *= stats.GROUND_FRICTION
	
	player.move_and_slide()
	
	context.time_since_on_ground = 0

	if not player.is_on_floor():
		finished.emit(AIRBORNE)
	elif context.time_since_jump_pressed < 0.1:
		finished.emit(JUMP)
