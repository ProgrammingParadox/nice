extends PlayerState

var attacking_position: Vector2


func enter(previous_state_path: String, data := { }) -> void:
	if not data.has("position"):
		print("Dash not passed a position")
		finished.emit("airborne")

		return

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
		finished.emit(AIRBORNE)

	for action in cancel_actions:
		if Input.is_action_pressed(action):
			print("dash cancelled", action)
			finished.emit(AIRBORNE)
			return

	if (player.position - attacking_position).length() < 1:
		finished.emit(AIRBORNE)
