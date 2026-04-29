extends PlayerState

var attacking_position: Vector2
var attacking_reference

var path: Array[Vector2]


func enter(previous_state_path: String, data := { }) -> void:
	if not data.has("position"):
		print("Dash not passed a position")
		finished.emit("airborne")

		return

	if data.has("reference"):
		attacking_reference = data.reference

	if data.has("path"):
		path = data.path

		path.pop_back()

	attacking_position = data.position

	var direction: Vector2 = (attacking_position - player.position).normalized()

	# velocity-based dash
	player.velocity = direction * stats.DASH_VELOCITY


var cancel_actions = [
	#"left",
	#"up",
	#"right",
	"down",
]


func physics_update(delta: float) -> void:
	#player.position = lerp(player.position, attacking_position, 0.4)

	# stop overshooting!
	var dash_speed = 30.0
	# @TODO: move to player stat or whatever
	var direction: Vector2 = (attacking_position - player.position).normalized()
	if attacking_position.distance_to(player.position) >= dash_speed:
		player.position += direction * dash_speed
	else:
		player.position = attacking_position

		if (attacking_reference != null) and ("is_dead" in attacking_reference):
			attacking_reference.is_dead = true

		if path.size() != 0:
			finished.emit(DASH)
		else:
			finished.emit(AIRBORNE)

	for action in cancel_actions:
		if Input.is_action_pressed(action):
			print("dash cancelled", action)
			finished.emit(AIRBORNE)
			return

	if (player.position - attacking_position).length() < 1:
		if (attacking_reference != null) and ("is_dead" in attacking_reference):
			attacking_reference.is_dead = true

		if path.size() != 0:
			finished.emit(DASH)
		else:
			finished.emit(AIRBORNE)

	if context.dash_path_handler:
		await context.dash_path_handler.ready
		var points: Array[Vector2] = context.dash_path_handler.find_dash_path()
		context.dash_path_handler.dash_path_to_lines(points)
