class_name PlayerState extends State

const GROUNDED = "grounded"
const AIRBORNE = "airborne"
const WALL_CLING = "wall_cling"
const JUMP = "jump"
const WALL_JUMP = "wall_jump"

var player: Player

var context: PlayerContext
var stats  : PlayerStats


func _ready() -> void:
	await owner.ready
	
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
	
	context = player.context
	stats   = player.stats
	
func _physics_process(delta: float) -> void:
	context.time_since_jump_pressed += delta
	context.time_since_on_ground += delta
	
	if Input.is_action_just_pressed("up"):
		context.time_since_jump_pressed = 0
