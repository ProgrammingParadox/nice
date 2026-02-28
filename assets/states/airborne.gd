extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	pass

func physics_update(delta: float) -> void:
	super(delta)
	
	var direction := Input.get_axis("left", "right")
	player.velocity.x += stats.ACCELERATION * direction * delta * 20
	
	player.velocity.x = clamp(player.velocity.x, -stats.MAX_SPEED, stats.MAX_SPEED)
	player.velocity.x *= stats.AIR_FRICTION
	
	player.velocity += player.get_gravity() * delta
	
	player.move_and_slide()

	if (
		context.time_since_on_ground < 0.5 and 
		context.time_since_jump_pressed < 0.1
	):
		finished.emit(JUMP)
	elif player.is_on_floor():
		finished.emit(GROUNDED)
