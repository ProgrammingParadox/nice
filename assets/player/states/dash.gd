extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	#player.velocity.y = stats.JUMP_VELOCITY

	# I don't like this at all, but we're in different scenes
	var enemies = get_node("../../../Enemies").get_children()

	var ray: RayCast2D = player.get_node("rays/dash_ray")

	var closest_distance = INF
	var closest_ref
	for i in range(len(enemies)):
		var enemy = enemies.get(i)
		var distance = player.position.distance_to(enemy.position)

		if distance < stats.MIN_AUTOAIM_DASH_DISTANCE:
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

	# @TODO: make direction pressed be the default dash if
	# aim-assist can't help

	# no enemies, or a bug :/
	if typeof(closest_ref) == TYPE_NIL:
		print("no closest_ref")
		finished.emit(AIRBORNE)
		return

	var distance = closest_ref.position.distance_to(player.position)
	if distance > stats.MAX_AUTOAIM_DASH_DISTANCE:
		print("too far to dash!")
		finished.emit(AIRBORNE)
		return

	#var direction: Vector2 = (closest_ref.position - player.position).normalized()

	# velocity-based dash
	#context.dash_vel = direction * stats.DASH_VELOCITY

	#finished.emit(AIRBORNE)

	# Dashing-state based
	player.velocity = Vector2.ZERO
	finished.emit(
		DASHING,
		{
			"position": closest_ref.position,
		},
	)


func physics_update(delta: float) -> void:
	pass
