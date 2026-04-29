class_name DashPathHandler
extends Node2D

@export var ray: RayCast2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func find_dash_candidate(
		start_position: Vector2,
		enemies: Array[Node],
		player: Player,
		criteria: Callable = func(_e): return true,
		set_candidacy: bool = true,
) -> CharacterBody2D:
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
			distance < player.stats.MIN_AUTOAIM_DASH_DISTANCE or
			distance > player.stats.MAX_AUTOAIM_DASH_DISTANCE
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


func clear_dash_path():
	$dash_path_indicator.clear_points()


func dash_path_to_lines(path: Array[Vector2]):
	var dash_path_indicator = $dash_path_indicator
	clear_dash_path()
	for point in path:
		# self.position is kept here because the dash path is relative to the player's position
		dash_path_indicator.add_point(self.to_local(point))
