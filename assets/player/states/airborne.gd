extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	context.gravity_mod = 1


func exit() -> void:
	context.gravity_mod = 1


func find_dash_candidate() -> CharacterBody2D:
	# I don't like this at all, but we're in different scenes

	var enemies = get_node("../../../Enemies").get_children()

	var ray: RayCast2D = player.get_node("rays/dash_ray")

	var closest_distance = INF
	var closest_ref: CharacterBody2D
	for i in range(len(enemies)):
		var enemy = enemies.get(i)
		enemy.is_dash_candidate = false

		var distance = player.position.distance_to(enemy.position)
		if (
			distance < stats.MIN_AUTOAIM_DASH_DISTANCE or
			distance > stats.MAX_AUTOAIM_DASH_DISTANCE
		):
			continue

		# Check if aim-assist would be useful
		# (like, if there's a clear line of sight to
		# the enemy)
		var intersects = false
		ray.target_position = enemy.position - player.position
		ray.force_raycast_update()
		if ray.is_colliding():
			var collision = ray.get_collider()
			var point = ray.get_collision_point()

			if collision == enemy:
				intersects = true

		if not intersects:
			continue

		if distance < closest_distance:
			closest_distance = distance
			closest_ref = enemy

	# no enemies, or a bug :/
	if typeof(closest_ref) == TYPE_NIL:
		return null

	return closest_ref


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

	var dash_candidate = find_dash_candidate()
	if dash_candidate != null:
		dash_candidate.is_dash_candidate = true

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
