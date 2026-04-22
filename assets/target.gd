extends Node2D

var last_target: Vector2 = Vector2.ZERO
var cur_target: Vector2 = Vector2.ZERO

@export var transitional_target: Node2D

# maybe, use tweens sometime?
# would need to cancel the tween if the target moved

@export var duration: float = 0.09

var tween: Tween


func start_animation():
	if tween:
		tween.kill()
	tween = create_tween()

	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "position", transitional_target.position, duration)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if transitional_target.position != last_target:
		start_animation()
		last_target = cur_target
		cur_target = transitional_target.position

	#print(transitional_target.position)

	#self.position = transitional_target.position
