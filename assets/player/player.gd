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


func find_dash_candidate() -> CharacterBody2D:
	# I don't like this at all, but we're in different scenes

	#var enemies = get_node("../../Enemies").get_children()
	var enemies = context.enemies

	var ray: RayCast2D = get_node("rays/dash_ray")

	var closest_distance = INF
	var closest_ref: CharacterBody2D
	for i in range(len(enemies)):
		var enemy = enemies.get(i)
		enemy.is_dash_candidate = false

		if enemy.is_dead:
			continue

		var distance = self.position.distance_to(enemy.position)
		if (
			distance < stats.MIN_AUTOAIM_DASH_DISTANCE or
			distance > stats.MAX_AUTOAIM_DASH_DISTANCE
		):
			continue

		# Check if aim-assist would be useful
		# (like, if there's a clear line of sight to
		# the enemy)
		var intersects = false
		ray.target_position = enemy.position - self.position
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

	closest_ref.is_dash_candidate = true

	return closest_ref
