extends CharacterBody2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity", 980) / 100
@export var WALK_SPEED = 500
@export var JUMP_STRENGTH = -1800
@export var GRAVITY_SCALE: float = 10
@export var RUN_SCALE: float = 2

var left_most_x_position: float = -999999
func _ready():
	$AnimatedSprite2D.play("idle")

var jump_count = 0
var is_running = false
var is_double_jumping = false
func _physics_process(_delta):
	var gravity = GRAVITY_SCALE * GRAVITY
	velocity.y += gravity
	
	# Don't let go back
	if position.x < left_most_x_position:
		position.x = left_most_x_position
	
	# Handle horizontal movement
	if Input.is_action_pressed("move_right"):
		velocity.x = WALK_SPEED
	elif Input.is_action_pressed("move_left"):
		velocity.x = -WALK_SPEED
	else:
		velocity.x = 0
		
	# Handle runing
	if Input.is_action_pressed("move_run"):
		velocity.x *= RUN_SCALE
		is_running = true
	else:
		is_running = false

	# Handle jump
	if is_on_floor():
		jump_count = 0
		is_double_jumping = false
		
	if Input.is_action_just_pressed("move_jump"):
		if jump_count == 0:
			# Normal jump
			if velocity.y > 0:
				velocity.y = 0
			velocity.y += JUMP_STRENGTH
			jump_count += 1
		elif jump_count == 1:
			# Double jump
			if velocity.y > 0:
				velocity.y = 0
			velocity.y += JUMP_STRENGTH
			is_double_jumping = true
			jump_count += 1

	if Input.is_action_pressed("move_down"):
		velocity.y = 30 * gravity
		
	move_and_slide()
	
	handle_animation()
	
func handle_animation():
	var current_animation
	var hflip = $AnimatedSprite2D.flip_h
	
	# Increase animation speed while running
	if is_running:
		$AnimatedSprite2D.speed_scale = RUN_SCALE
	else:
		$AnimatedSprite2D.speed_scale = 1
	
	if velocity.is_zero_approx():
		# Standing still
		current_animation = "idle"
	else:
		current_animation = "run"
	
	# Determine which side to face
	if global_position.x - get_global_mouse_position().x > 0:
		# Flip
		hflip = true
	else:
		hflip= false

	
	
	# In 2D down is positive y
	if velocity.y > 0 and not velocity.is_zero_approx():
		current_animation = "fall"
		
	elif velocity.y < 0 and not velocity.is_zero_approx():
		current_animation = "jump"
	
	if is_double_jumping and velocity.y < 0:
		current_animation = "double_jump"
	
	$AnimatedSprite2D.play(current_animation)
	$AnimatedSprite2D.flip_h = hflip



func _on_camera_2d_moved(camera):
	# Calculate possible lowest x position of the character

	var _left_most_x_position = position.x - (get_viewport_rect().size.x / 2)
	left_most_x_position = _left_most_x_position
