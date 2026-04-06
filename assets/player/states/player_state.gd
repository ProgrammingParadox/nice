class_name PlayerState
extends State

const GROUNDED = "grounded"
const AIRBORNE = "airborne"
const WALL_CLING = "wall_cling"
const JUMP = "jump"
const WALL_JUMP = "wall_jump"
const DASH = "dash"
const DASHING = "dashing"

var player: Player

var context: PlayerContext
var stats: PlayerStats


func _ready() -> void:
	await owner.ready

	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

	context = player.context
	stats = player.stats


func _physics_process(delta: float) -> void:
	context.time_since_left_pressed += delta
	context.time_since_right_pressed += delta
	context.time_since_jump_pressed += delta
	context.time_since_last_jump_pressed += delta
	context.time_since_on_ground += delta
	context.time_since_left_wall_touch += delta
	context.time_since_right_wall_touch += delta

	if Input.is_action_just_pressed("left"):
		context.time_since_left_pressed = 0
	if Input.is_action_just_pressed("right"):
		context.time_since_right_pressed = 0

	if Input.is_action_just_pressed("up"):
		context.time_since_jump_pressed = 0
	if Input.is_action_pressed("up"):
		context.time_since_last_jump_pressed = 0

	if player.left_wall_area_collided:
		context.time_since_left_wall_touch = 0
	if player.right_wall_area_collided:
		context.time_since_right_wall_touch = 0
