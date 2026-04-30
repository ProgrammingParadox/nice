extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	for e in context.enemies:
		e.is_dash_candidate = false

	if context.dash_path_handler:
		context.dash_path_handler.clear_dash_path()

	if context.time_since_jump_pressed < 0.1:
		finished.emit(JUMP)


func physics_update(delta: float) -> void:
	super(delta)

	var direction := Input.get_axis("left", "right")
	var diff = context.time_since_right_pressed - context.time_since_left_pressed
	var last_direction = 1.0 if diff < 0 else -1.0

	var both = Input.is_action_pressed("left") and Input.is_action_pressed("right")

	var r_direction = last_direction if both else direction

	player.velocity.x += stats.ACCELERATION * r_direction * delta * 20

	player.velocity.x = clamp(player.velocity.x, -stats.MAX_SPEED, stats.MAX_SPEED)
	player.velocity.x *= stats.GROUND_FRICTION

	player.move_and_slide()

	context.time_since_on_ground = 0
	context.jumps = 0

	context.dash_vel = Vector2.ZERO

	if not player.is_on_floor():
		finished.emit(AIRBORNE)
	elif context.time_since_jump_pressed < 0.1:
		finished.emit(JUMP)
