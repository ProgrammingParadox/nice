extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	context.gravity_mod = 1


func exit() -> void:
	context.gravity_mod = 1


func physics_update(delta: float) -> void:
	super(delta)

	var direction := Input.get_axis("left", "right")
	var diff = context.time_since_right_pressed - context.time_since_left_pressed
	var last_direction = 1.0 if diff < 0 else -1.0

	var both = Input.is_action_pressed("left") and Input.is_action_pressed("right")

	var r_direction = last_direction if both else direction

	player.velocity.x += stats.ACCELERATION * r_direction * delta * 20

	player.velocity.x = clamp(player.velocity.x, -stats.MAX_SPEED, stats.MAX_SPEED)
	player.velocity.x *= stats.AIR_FRICTION

	player.velocity += player.get_gravity() * context.gravity_mod * delta

	#if abs(context.dash_vel.length()) > 0.1:
	player.velocity += context.dash_vel

	context.dash_vel *= 0.8

	player.move_and_slide()

	player.find_dash_candidate()

	var points: Array[Vector2] = player.find_dash_path()
	player.dash_path_to_lines(points)

	if not Input.is_action_pressed("up"):
		context.gravity_mod = 1.5

	if Input.is_action_just_pressed("down"):
		#context.gravity_mod = 4
		player.velocity.y += 300

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

	if Input.is_action_just_pressed("dash"):
		finished.emit(DASH)
		return

	if Input.is_action_just_pressed("take_path"):
		finished.emit(
			DASH,
			{
				"path": points,
			},
		)
		return
