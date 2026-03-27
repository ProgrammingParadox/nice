extends PlayerState

func enter(previous_state_path: String, data := { }) -> void:
	#player.velocity.y = stats.JUMP_VELOCITY

	# I don't like this at all, but we're in different scenes
	var enemies = get_node("../../../Enemies").get_children()

	var closest_distance = INF
	var closest_ref
	for i in range(len(enemies)):
		var enemy = enemies.get(i)
		var distance = player.position.distance_squared_to(enemy.position)

		if distance < closest_distance:
			closest_distance = distance
			closest_ref = enemy

	# no enemies, or a bug :/
	if null == closest_ref:
		return

	var direction: Vector2 = (closest_ref.position - player.position).normalized()

	context.dash_vel = direction * stats.DASH_VELOCITY

	finished.emit(AIRBORNE)


func physics_update(delta: float) -> void:
	pass
