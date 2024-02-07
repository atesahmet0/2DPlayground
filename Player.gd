extends CharacterBody2D

signal character_died

enum STATE {WALK, RUN, JUMP, FALL, DASH, IDLE, DEAD}

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
@export var DASH_DURATION: float = 100

var left_most_x_position: float = -999999
var current_health = 0
var current_state = STATE.IDLE
var jump_count = 0
var is_running = false
var is_double_jumping = false
var last_dash_time = 0

func _ready():
	current_health = HEALTH
	$AnimatedSprite2D.play("idle")

func _physics_process(_delta):
	# Handle gravity
	var gravity = GRAVITY_SCALE * GRAVITY
	velocity.y += gravity
	
	# Check if felt to void
	if void_beginning < position.y:
		died()
	
	# Don't let go back
	if position.x < left_most_x_position:
		position.x = left_most_x_position
	
	# Finish dash after duration ends
	if Time.get_ticks_msec() - last_dash_time > DASH_DURATION:
		current_state = STATE.IDLE
	
	# Handle horizontal movement
	
	# Ignore movement whilst dash
	if current_state == STATE.DASH:
		pass
	elif Input.is_action_pressed("move_right"):
		velocity.x = WALK_SPEED
		current_state = STATE.WALK
	elif Input.is_action_pressed("move_left"):
		velocity.x = -WALK_SPEED
		current_state = STATE.WALK
	else:
		velocity.x = 0
		
	# Handle runing
	if Input.is_action_pressed("move_run") and current_state == STATE.WALK:
		current_state = STATE.RUN
	
	if current_state == STATE.RUN:
		velocity.x *= 2
	
	# Handle jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y += JUMP_STRENGTH
		current_state = STATE.JUMP
	
	if velocity.y < 0:
		if not Input.is_action_pressed("move_jump") and not Input.is_action_just_pressed("move_jump"):
			# If moving up and jump button released then don't jump anymore
			velocity.y /= 4 
	
	if Input.is_action_just_pressed("move_down"):
			velocity.y = 60 * GRAVITY
		
	if Input.is_action_just_pressed("move_dash") and current_state != STATE.DASH:
		current_state = STATE.DASH
		last_dash_time = Time.get_ticks_msec()
		velocity.x *= 1 + ((DASH_DURATION - Time.get_ticks_msec() + last_dash_time) / DASH_DURATION * 3)
	
	# Get down from platform
	if Input.is_action_just_pressed("move_down") and is_on_floor():
		position.y += 2
	
	move_and_slide()


var is_dead = false
func _process(delta):
	# Handle health label
	$HealthLabel.text = str(3 - hit_count)
	
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
	
	if current_state == STATE.DASH:
		current_animation = "dash"
	
	$AnimatedSprite2D.play(current_animation)
	$AnimatedSprite2D.flip_h = hflip

func died():
	current_state = STATE.DEAD
	is_dead = true
	character_died.emit()
	
func on_enemy_hit(enemy: CharacterBody2D):
	current_health -= 10 / HEALTH_RESISTANCE
	if current_health <= 0:
		died()
		
func _on_camera_2d_moved(camera):
	# Calculate possible lowest x position of the character
	var _left_most_x_position = position.x - (get_viewport_rect().size.x / 2)
	left_most_x_position = _left_most_x_position

var hit_count = 0
func got_hit():
	hit_count += 1
	if hit_count > 2:
		died()
