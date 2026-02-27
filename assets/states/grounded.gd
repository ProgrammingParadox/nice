extends Node

var player: CharacterBody2D
var context: PlayerContext

func enter() -> void: pass
func exit() -> void: pass

func physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		var vel = (SPEED * direction * delta * 20)
		if not is_on_floor():
			vel *= AIRTIME_X_VEL_MOD

		player.velocity.x += vel
