extends StaticBody2D

enum STATE {UP, DOWN, STATIONARY}

@export var OFFSET = Vector2(0, -64)
@export var DURATION: float = 4.0 

var current_state = STATE.UP

var offset = 0
var initial_position = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = global_position
	offset = global_position + OFFSET
	start_tween()


func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property(self, "position", offset, DURATION / 2)
	tween.tween_property(self, "position", initial_position, DURATION / 2)

