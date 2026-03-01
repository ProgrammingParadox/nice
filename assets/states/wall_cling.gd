extends PlayerState

var from_direction = 0


func enter(previous_state_path: String, data := { }) -> void:
	from_direction = data.direction


func physics_update(delta: float) -> void:
	super(delta)

	var direction = Input.get_axis("left", "right")
	var aligned = sign(from_direction) == sign(direction)

	player.velocity += player.get_gravity() * delta

	player.velocity.y = min(player.velocity.y, stats.MAX_WALL_CLING_SPEED)

	player.move_and_slide()

	context.jumps = 0

	if (
		context.time_since_last_jump_pressed < 0.5 and (
			(context.time_since_left_wall_touch < 0.5 and Input.is_action_just_pressed("right")) or
			(context.time_since_right_wall_touch < 0.5 and Input.is_action_just_pressed("left"))
		)
	):
		finished.emit(WALL_JUMP, { "direction": -from_direction })
		return

	if direction == 0 or not (
		player.left_wall_area_collided or
		player.right_wall_area_collided
	):
		finished.emit(AIRBORNE)
		return

	if player.is_on_floor():
		finished.emit(GROUNDED)
		return

	if not aligned:
		finished.emit(AIRBORNE)
		return
