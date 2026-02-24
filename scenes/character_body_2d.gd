extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const WALL_FRICTION = 0.8

var time_since_on_ground = -1
var time_since_last_wall_touch = -1
var time_since_last_wall_jump = -1

var time_since_jump_pressed = INF

var gravity_mod := 1.0


func _physics_process(delta: float) -> void:
	# keep track of jumping
	time_since_jump_pressed += delta
	if Input.is_action_pressed("up"):
		time_since_jump_pressed = 0

	# For a jump buffer
	var jump = time_since_jump_pressed < 0.1

	# Add the gravity, keep track of time_since_on_ground
	if is_on_floor():
		time_since_on_ground = 0
	else:
		velocity += (get_gravity() * gravity_mod) * delta

		time_since_on_ground += delta

	# Rays for detecting walls
	var left_wall_area_collided = (
		$wall_jump_areas/left_wall_area.has_overlapping_bodies() and
		$wall_jump_areas/left_wall_area.get_overlapping_bodies().find_custom(
			func(b) -> bool: return b is TileMapLayer,
		) != -1
	)
	var right_wall_area_collided = (
		$wall_jump_areas/right_wall_area.has_overlapping_bodies() and
		$wall_jump_areas/right_wall_area.get_overlapping_bodies().find_custom(
			func(b) -> bool: return b is TileMapLayer,
		) != -1
	)
	var top_wall_area_collided = (
		$wall_jump_areas/top_wall_area.has_overlapping_bodies() and
		$wall_jump_areas/top_wall_area.get_overlapping_bodies().find_custom(
			func(b) -> bool: return b is TileMapLayer,
		) != -1
	)

	# Sliding against walls, keep track of time_since_last_wall_touch
	if (
		(left_wall_area_collided or right_wall_area_collided)
		and not is_on_floor()
	):
		time_since_last_wall_touch = 0

		if Input.get_axis("left", "right") != 0 and velocity.y > 0.0:
			velocity.y *= WALL_FRICTION
	else:
		time_since_last_wall_touch += delta

	#print(time_since_last_wall_touch)

	# Handle jump
	if jump and time_since_on_ground < 0.1:
		velocity.y = JUMP_VELOCITY

	print("Jump: ", jump, " Time since ground: ", time_since_on_ground, " y vel: ", self.velocity.y)

	# fast falling/variable jump height
	if not jump and velocity.y < 0:
		gravity_mod = 3
	else:
		gravity_mod = 1

	# Wall jumping
	time_since_last_wall_jump += delta
	if (
		not top_wall_area_collided and
		jump and
		time_since_last_wall_touch < 0.1 and
		time_since_last_wall_jump > 1
	):
		if left_wall_area_collided and Input.is_action_pressed("right"):
			velocity.x = -JUMP_VELOCITY * 0.7
			velocity.y = JUMP_VELOCITY
		if right_wall_area_collided and Input.is_action_pressed("left"):
			velocity.x = JUMP_VELOCITY * 0.7
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
