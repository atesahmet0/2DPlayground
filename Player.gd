extends CharacterBody2D

signal character_died

enum SUPER_STATE {ATTACK0, ATTACK1, DASH, NONE}
enum STATE {WALK, RUN, JUMP, FALL, IDLE, DEAD}

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity", 980) / 100

# When characte's y value is lesser than this character felt to void.
@export var void_beginning: float = 5000

@export_category("Player Properties")
@export var WALK_SPEED = 200
@export var JUMP_STRENGTH = -650
@export var GRAVITY_SCALE: float = 2
@export var RUN_SCALE: float = 1.5
@export var HEALTH: float = 100
@export var HEALTH_RESISTANCE: float = 50
# As milisecond
@export var DASH_DURATION: float = 500
# As milisecond
@export var JUMP_BUFFER_DURATION: float = 500

var left_most_x_position: float = -999999
var current_state = STATE.IDLE
var current_super_state: SUPER_STATE = SUPER_STATE.NONE
var last_attack_type: SUPER_STATE = SUPER_STATE.NONE
var super_state_order_queue: SuperStateOrderQueue


func _ready():
	super_state_order_queue = SuperStateOrderQueue.new() 


func _physics_process(_delta):
	if position.y > void_beginning:
		died()
	
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * GRAVITY_SCALE
	
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x = WALK_SPEED
	if Input.is_action_pressed("move_left"):
		velocity.x = -WALK_SPEED
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_STRENGTH
	
	match super_state_order_queue.next().order_type:
		SUPER_STATE.NONE:
			if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("attack"):
				super_state_order_queue.add(SuperStateOrder.new(SUPER_STATE.ATTACK0, 1000))
		SUPER_STATE.ATTACK0:
			if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("attack"):
				super_state_order_queue.add(SuperStateOrder.new(SUPER_STATE.ATTACK1, 1000))
		SUPER_STATE.ATTACK1:
			if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("attack"):
				super_state_order_queue.add(SuperStateOrder.new(SUPER_STATE.ATTACK0, 1000))
		SUPER_STATE.DASH:
			pass
	move_and_slide()


func _process(delta):
	handle_animation()


func handle_animation():
	var hflip = $AnimatedSprite2D.flip_h
	# Determine which side to face
	if global_position.x - get_global_mouse_position().x > 0:
		# Flip
		hflip = true
	else:
		hflip= false
	$SlashBox.rotation_degrees = 180 if hflip else 0
	$AnimatedSprite2D.flip_h = hflip
	
	var current_animation = "idle"
	match super_state_order_queue.next().order_type:
		SUPER_STATE.NONE:
			if velocity.is_zero_approx():
				current_animation = "idle"
			elif velocity.y > 0:
				current_animation = "fall"
			elif velocity.y < 0:
				current_animation = "jump"
			else:
				current_animation = "run"
		SUPER_STATE.ATTACK0:
			current_animation = "attack0"
		SUPER_STATE.ATTACK1:
			current_animation = "attack1"
	
	$AnimatedSprite2D.play(current_animation)


func died():
	current_state = STATE.DEAD
	character_died.emit()


func on_enemy_hit(enemy: CharacterBody2D):
	died()


func _on_camera_2d_moved(camera):
	# Calculate possible lowest x position of the character
	var _left_most_x_position = position.x - (get_viewport_rect().size.x / 2)
	left_most_x_position = _left_most_x_position


var hit_count = 0
func got_hit():
	hit_count += 1
	if hit_count > 0:
		died()


# This function helps us to determine if collided body is player.
# usage node2d.has_method("player_unique_function")
func player_unique_function():
	pass


# End superstate after animation finish
func _on_animated_sprite_2d_frame_changed():
	match super_state_order_queue.next().order_type:
		SUPER_STATE.NONE:
			return
		SUPER_STATE.ATTACK0:
			if $AnimatedSprite2D.get_frame() == 3:
				super_state_order_queue.pop()
			elif $AnimatedSprite2D.get_frame() == 1:
				# Deal damage
				var bodies = $SlashBox.get_overlapping_bodies()
				for body in bodies:
					if body != self:
						# Hit the target
						if body.has_method("got_hit"):
							body.got_hit()
		SUPER_STATE.ATTACK1:
			if $AnimatedSprite2D.get_frame() == 2:
				super_state_order_queue.pop()
			elif $AnimatedSprite2D.get_frame() == 0:
				# Deal damage
				var bodies = $SlashBox.get_overlapping_bodies()
				for body in bodies:
					if body != self:
						# Hit the target
						if body.has_method("got_hit"):
							body.got_hit()


class SuperStateOrder:
	# Time each order can persist. As msec
	var order_time: float
	var order_duration: float
	var order_type: SUPER_STATE


	func _init(_order_type: SUPER_STATE, _order_duration: float):
		order_duration = _order_duration
		order_type = _order_type
		order_time = Time.get_ticks_msec()


class SuperStateOrderQueue:
	var _orders: Array[SuperStateOrder]
	var _dummy: SuperStateOrder


	func _init():
		_dummy = SuperStateOrder.new(SUPER_STATE.NONE, 0)


	func add(order: SuperStateOrder):
		_orders.push_back(order)


	func pop() -> SuperStateOrder:
		var current_order: SuperStateOrder = _orders.pop_front()
		while current_order != null and Time.get_ticks_msec() - current_order.order_time > current_order.order_duration:
			current_order = _orders.pop_front()
		return current_order


	func next() -> SuperStateOrder:
		return _orders[0] if _orders.size() > 0 else _dummy
