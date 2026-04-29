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


func find_dash_candidate():
	return context.dash_path_handler.find_dash_candidate(self.global_position, context.enemies, self)


func find_dash_path(starting_position: Vector2 = self.position, max_depth: int = 50) -> Array[Vector2]:
	var points: Array[Vector2] = [starting_position]
	while points.size() < max_depth:
		var dash_candidate = context.dash_path_handler.find_dash_candidate(
			points.back(),
			context.enemies,
			self,
			func(e): return not points.has(e.position),
			false,
		)

		if dash_candidate == null:
			return points

		points.append(dash_candidate.global_position)

	return points
