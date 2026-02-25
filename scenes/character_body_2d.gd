extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const MAX_WALL_CLING_SPEED = 100

var time_since_on_ground = INF
var time_since_last_wall_touch = INF
var time_since_last_wall_jump = INF

var time_since_jump_pressed = INF

var gravity_mod := 1.0
var velocity_c_x = 0.0


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
			velocity.y = min(velocity.y, MAX_WALL_CLING_SPEED)
	else:
		time_since_last_wall_touch += delta

	#print(time_since_last_wall_touch)

	# Handle jump
	if jump and time_since_on_ground < 0.1:
		velocity.y = JUMP_VELOCITY

	#print("Jump: ", jump, " Time since ground: ", time_since_on_ground, " y vel: ", self.velocity.y)

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
		time_since_last_wall_jump > 0.1
	):
		if (
			left_wall_area_collided and
			not right_wall_area_collided and
			Input.is_action_pressed("right")
		):
			velocity.x = -JUMP_VELOCITY * 1
			velocity.y = JUMP_VELOCITY

			time_since_last_wall_jump = 0
		if (
			right_wall_area_collided and
			not left_wall_area_collided and
			Input.is_action_pressed("left")
		):
			velocity.x = JUMP_VELOCITY * 1
			velocity.y = JUMP_VELOCITY

			time_since_last_wall_jump = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		#velocity.x = direction * SPEED
		velocity.x = (SPEED * direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	#velocity.x *= 0.9

	move_and_slide()
