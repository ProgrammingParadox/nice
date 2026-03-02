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

	#func _physics_process(delta: float) -> void:
	#print(context.time_since_last_jump_pressed)
	#print(context.time_since_jump_pressed < 0.5, " ", context.time_since_on_ground < 0.5)
