extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var time_since_on_ground = -1
var time_since_last_wall_touch = -1
var time_since_last_wall_jump = -1


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		time_since_on_ground = 0
	else:
		velocity += get_gravity() * delta

		time_since_on_ground += delta

	var left_wall_ray_collided = (
		$wall_jump_rays/left_wall_ray.is_colliding() and
		$wall_jump_rays/left_wall_ray.get_collider() is TileMapLayer
	)
	var right_wall_ray_collided = (
		$wall_jump_rays/right_wall_ray.is_colliding() and
		$wall_jump_rays/right_wall_ray.get_collider() is TileMapLayer
	)

	if (
		(left_wall_ray_collided or right_wall_ray_collided)
		and not is_on_floor()
	):
		time_since_last_wall_touch = 0

		if Input.get_axis("left", "right") != 0:
			velocity.y *= 0.8
	else:
		time_since_last_wall_touch += delta

	#print(time_since_last_wall_touch)

	# Handle jump.
	if Input.is_action_pressed("up") and time_since_on_ground < 0.1:
		velocity.y = JUMP_VELOCITY

	time_since_last_wall_jump += delta
	if Input.is_action_pressed("up") and time_since_last_wall_touch < 0.1:
		if left_wall_ray_collided and Input.is_action_pressed("right"):
			velocity.x = -JUMP_VELOCITY * 0.2
			velocity.y = JUMP_VELOCITY
		if right_wall_ray_collided and Input.is_action_pressed("left"):
			velocity.x = JUMP_VELOCITY * 0.2
			velocity.y = JUMP_VELOCITY

		time_since_last_wall_jump = 1000

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
