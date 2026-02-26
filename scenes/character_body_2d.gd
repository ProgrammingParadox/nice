extends CharacterBody2D

const SPEED = 200.0 # actually acceleration...
const MAX_SPEED = 200.0
const JUMP_VELOCITY = -350.0
const WALL_JUMP_VELOCITY = JUMP_VELOCITY * 0.7
const MAX_WALL_CLING_SPEED = 100
const AIRTIME_X_VEL_MOD = 0.9

var time_since_on_ground = INF
var time_since_last_wall_touch = INF
var time_since_last_wall_jump = INF

var time_since_jump_pressed = INF

var jumps = 0

var gravity_mod := 1.0
var velocity_c_x = 0.0

var dead_actions = []


func _physics_process(delta: float) -> void:
	# because array.erase doesn't support
	# the functionality while looping
	# over the array, we'll buffer actions
	# that need to be removed. I don't like
	# it, but whatever.
	var to_remove = []
	for action in dead_actions:
		if not Input.is_action_pressed(action):
			to_remove.append(action)

	for action in to_remove:
		dead_actions.erase(action)

	# keep track of jumping
	time_since_jump_pressed += delta
	if not "up" in dead_actions and Input.is_action_pressed("up"):
		time_since_jump_pressed = 0

	# For a jump buffer
	var jump = time_since_jump_pressed < 0.1

	# Add the gravity, keep track of time_since_on_ground
	if is_on_floor():
		time_since_on_ground = 0
		jumps = 0
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

	# Handle jump
	if (
		not "up" in dead_actions and
		jump and
		(
			time_since_on_ground < 0.1 or
			(
				jumps != 0 and jumps < 2 # double jump
			)
		)
	):
		velocity.y = JUMP_VELOCITY
		jumps += 1

		dead_actions.append("up")

	# fast falling/variable jump height
	if not Input.is_action_pressed("up") and velocity.y < 0:
		gravity_mod = 3
	else:
		gravity_mod = 1

	# Wall jumping
	time_since_last_wall_jump += delta
	if left_wall_area_collided or right_wall_area_collided:
		jumps = 0
	if (
		jump and
		not is_on_floor() and
		time_since_last_wall_touch < 0.1 and
		time_since_last_wall_jump > 0.1
	):
		if (
			left_wall_area_collided and
			not right_wall_area_collided and
			Input.is_action_pressed("right") and
			not "right" in dead_actions
		):
			velocity.x = -WALL_JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY

			time_since_last_wall_jump = 0
			jumps += 1

			dead_actions.append("right")
		if (
			right_wall_area_collided and
			not left_wall_area_collided and
			Input.is_action_pressed("left") and
			not "left" in dead_actions
		):
			velocity.x = WALL_JUMP_VELOCITY
			velocity.y = JUMP_VELOCITY

			time_since_last_wall_jump = 0
			jumps += 1

			dead_actions.append("left")

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		var vel = (SPEED * direction * delta * 20)
		if not is_on_floor():
			vel *= AIRTIME_X_VEL_MOD

		velocity.x += vel

	velocity.x *= 0.8
	velocity.x = min(MAX_SPEED, velocity.x)

	move_and_slide()

	print(jumps, " ", dead_actions)
