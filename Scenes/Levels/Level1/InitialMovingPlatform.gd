extends AnimatableBody2D

enum STATE {MOVE, FALL, ABOUT_TO_FALL}

@export var OFFSET = Vector2(0, -64)
@export var DURATION: float = 4.0 
@export var fall_on_touch: bool = false
@export var delay_before_fall: float = 500

var current_state = STATE.MOVE

var offset = 0
var initial_position = 0
var current_tween = null


func _ready():
	initial_position = global_position
	offset = global_position + OFFSET
	start_tween()


var last_fall_order_time = -1
func _physics_process(delta):
	if fall_on_touch and current_state != STATE.FALL and $Area2D.has_overlapping_bodies():
		for i in $Area2D.get_overlapping_bodies():
			if i.has_method("player_unique_function"):
				# Player detected, fall after delay
				if current_state != STATE.MOVE:
					continue
				current_state = STATE.ABOUT_TO_FALL
				last_fall_order_time = Time.get_ticks_msec()
	if current_state == STATE.ABOUT_TO_FALL and Time.get_ticks_msec() - last_fall_order_time > delay_before_fall:
		fall()


func fall():
	if current_state == STATE.FALL:
		return
	
	current_state = STATE.FALL
	
	if current_tween:
		current_tween.kill()
	current_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	current_tween.set_parallel(false)
	
	var last_position = initial_position + Vector2(0, 2000)
	current_tween.tween_property(self, "position", last_position, 3.0)


func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property(self, "position", offset, DURATION / 2)
	tween.tween_property(self, "position", initial_position, DURATION / 2)
	current_tween = tween
