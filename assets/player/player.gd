class_name Player
extends CharacterBody2D

# constants and stuff
@export var stats: PlayerStats

# things like health
@export var context: PlayerContext

var left_wall_area_collided: bool:
	get:
		return (
			%left_wall_area.has_overlapping_bodies() and
			%left_wall_area.get_overlapping_bodies().find_custom(
				func(b) -> bool: return b is TileMapLayer,
			) != -1
		)
var right_wall_area_collided: bool:
	get:
		return (
			%right_wall_area.has_overlapping_bodies() and
			%right_wall_area.get_overlapping_bodies().find_custom(
				func(b) -> bool: return b is TileMapLayer,
			) != -1
		)


func find_dash_candidate(
		start_position: Vector2 = self.position,
		criteria: Callable = func(_e): return true,
		set_candidacy: bool = true,
) -> CharacterBody2D:
	# I don't like this at all, but we're in different scenes

	#var enemies = get_node("../../Enemies").get_children()
	var enemies = context.enemies

	var ray: RayCast2D = get_node("rays/dash_ray")

	var closest_distance = INF
	var closest_ref: CharacterBody2D
	for i in range(len(enemies)):
		var enemy = enemies.get(i)

		if set_candidacy:
			enemy.is_dash_candidate = false

		if enemy.is_dead:
			continue

		var distance = start_position.distance_to(enemy.position)
		if (
			distance < stats.MIN_AUTOAIM_DASH_DISTANCE or
			distance > stats.MAX_AUTOAIM_DASH_DISTANCE
		):
			continue

		if criteria != null and not criteria.call(enemy):
			continue

		# Check if aim-assist would be useful
		# (like, if there's a clear line of sight to
		# the enemy)
		var intersects = false
		ray.global_position = start_position
		ray.target_position = ray.to_local(enemy.global_position) # enemy.position - start_position
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

	if set_candidacy:
		closest_ref.is_dash_candidate = true

	return closest_ref


func find_dash_path(starting_position: Vector2 = self.position, max_depth: int = 50) -> Array[Vector2]:
	var points: Array[Vector2] = [starting_position]
	while points.size() < max_depth:
		var dash_candidate = find_dash_candidate(points.back(), func(e): return not points.has(e.position), false)

		if dash_candidate == null:
			return points

		points.append(dash_candidate.position)

	return points


func clear_dash_path():
	$dash_path_indicator.clear_points()


func dash_path_to_lines(path: Array[Vector2]):
	var dash_path_indicator = $dash_path_indicator
	clear_dash_path()
	for point in path:
		# self.position is kept here because the dash path is relative to the player's position
		dash_path_indicator.add_point(point - self.position)
