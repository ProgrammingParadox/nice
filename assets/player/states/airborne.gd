extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	pass


func physics_update(delta: float) -> void:
	super(delta)

	var direction := Input.get_axis("left", "right")
	var diff = context.time_since_right_pressed - context.time_since_left_pressed
	var last_direction = 1.0 if diff < 0 else -1.0

	player.velocity.x += stats.ACCELERATION * direction * delta * 20

	player.velocity.x = clamp(player.velocity.x, -stats.MAX_SPEED, stats.MAX_SPEED)
	player.velocity.x *= stats.AIR_FRICTION

	player.velocity += player.get_gravity() * delta

	player.move_and_slide()

	if (
		context.time_since_last_jump_pressed < 0.1 and (
			(context.time_since_left_wall_touch < 0.5 and context.time_since_right_pressed < 0.5) or
			(context.time_since_right_wall_touch < 0.5 and context.time_since_left_pressed < 0.5)
		)
	):
		finished.emit(WALL_JUMP, { "direction": last_direction })
		return

	if Input.is_action_just_pressed("up") and context.jumps < stats.MAX_JUMPS:
		finished.emit(JUMP)
		return

	if (
		(
			player.left_wall_area_collided and direction < 0
		) or (
			player.right_wall_area_collided and direction > 0
		)
	):
		finished.emit(WALL_CLING, { "direction": direction })
		return

	# coyote
	if (
		context.time_since_on_ground < 0.5 and
		context.time_since_jump_pressed < 0.1
	):
		finished.emit(JUMP)
		return

	if player.is_on_floor():
		finished.emit(GROUNDED)
		return
