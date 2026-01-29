extends Node2D

@onready var rays = [
	[$Skeleton2D/rays/raycast_1, $targets/target_1, $transitional_targets/t_target_1],
	[$Skeleton2D/rays/raycast_2, $targets/target_2, $transitional_targets/t_target_2],
	[$Skeleton2D/rays/raycast_3, $targets/target_3, $transitional_targets/t_target_3],
	[$Skeleton2D/rays/raycast_4, $targets/target_4, $transitional_targets/t_target_4],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func v3(v: Vector2):
	return Vector3(v.x, v.y, 0.0);

func lerp(v0: float, v1: float, t: float):
	return (1 - t) * v0 + t * v1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	
	$Skeleton2D.global_position = mouse_pos;
	
	for ray_pair in rays:
		var ray = ray_pair[0];
		var target = ray_pair[1];
		var t_target = ray_pair[2];
		
		if target.global_position.distance_to(t_target.global_position) > 1:
			target.global_position = lerp(target.global_position, t_target.global_position, 0.2);;
		
		if ray == null || target == null:
			continue;
			
		ray.rotation = sin(Engine.get_physics_frames()) * 0.4;
		
		if ray.is_colliding():
			var point = ray.get_collision_point();
			
			# distance from collision point and the current foot position
			var distance = point.distance_to(target.global_position);
			
			if (
				(distance > 80) or 
				(target.global_position.distance_to(t_target.global_position) > 80)
			   ):
				t_target.global_position = point;
