extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const WALL_FRICTION = 0.8

var time_since_on_ground = -1
var time_since_last_wall_touch = -1
var time_since_last_wall_jump = -1

var time_since_jump_pressed = INF


func _physics_process(delta: float) -> void:
	time_since_jump_pressed += delta
	if Input.is_action_pressed("up"):
		time_since_jump_pressed = 0

	var jump = time_since_jump_pressed < 0.1

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

		if Input.get_axis("left", "right") != 0 and velocity.y > 0.0:
			velocity.y *= WALL_FRICTION
	else:
		time_since_last_wall_touch += delta

	#print(time_since_last_wall_touch)

	# Handle jump.
	if jump and time_since_on_ground < 0.1:
		velocity.y = JUMP_VELOCITY

	time_since_last_wall_jump += delta
	if jump and time_since_last_wall_touch < 0.1:
		if left_wall_ray_collided and Input.is_action_pressed("right"):
			velocity.x = -JUMP_VELOCITY * 0.2
			velocity.y = JUMP_VELOCITY
		if right_wall_ray_collided and Input.is_action_pressed("left"):
			velocity.x = JUMP_VELOCITY * 0.2
			velocity.y = JUMP_VELOCITY

		time_since_last_wall_jump = INF

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
