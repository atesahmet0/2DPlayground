extends CharacterBody2D

signal died(object)

enum STATE {RUN, HIT, JUMP, DEAD, IDLE}

@export var HEALTH: int = 100
@export var TARGET: Node2D
@export var SPEED: float = 50
@export var GRAVITY_SCALE: float = 2
@export var JUMP_SCALE: float = -700
# When target is above this point jump. As px.
@export var JUMP_THRESHOLD: float = 30
# Time between consecutive jumps
@export var JUMP_DELAY: float = 2000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") / 100

var current_health: float = 0
var current_state: STATE = STATE.IDLE
var is_flipped: bool = false

func _ready():
	current_health = HEALTH


var hit_animation = false
func _process(delta):
	# Handle animation
	match current_state:
		STATE.DEAD:
			return
		STATE.IDLE:
			$AnimatedSprite2D.play("idle")
		STATE.RUN:
			$AnimatedSprite2D.play("run")
		STATE.HIT:
			$AnimatedSprite2D.play("attack1")
	
	# TODO delete later
	$CircularBar.value = Time.get_ticks_msec() / 5 % 100
	
	# Only update when target is not reached to avoid jittering
	if not $NavigationAgent2D.is_target_reached():
		is_flipped = TARGET.global_position.x < global_position.x

	# Handle direction of sprites
	if is_flipped:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	call_deferred("actor_setup")


# If jump order is given for a whole interval then jump. If order is not present -1
var first_jump_order = -1
func _physics_process(delta):
	# If dead don't move
	if current_state == STATE.DEAD:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_SCALE
	
	# Handle direction of physcics objects
	if is_flipped:
		$SwingArea/CollisionShape2D.position.x = -10
	else:
		$SwingArea/CollisionShape2D.position.x = 10

	if not $NavigationAgent2D.is_target_reached():
		var next_path_position = $NavigationAgent2D.get_next_path_position()
		# This is a vector pointing towards target
		var desired_velocity = global_position.direction_to(next_path_position) * SPEED
		# Make horizontal velocity constant. If velocity.x is small don't move to avoid jittering
		velocity.x = sign(desired_velocity.x) * SPEED if abs(desired_velocity.x) > 10 else 0
		print("Desired velocity x: " + str(desired_velocity.x))
		# If target is on top jump
		if desired_velocity.y < 0 and global_position.y - TARGET.global_position.y > JUMP_THRESHOLD:
			if first_jump_order == -1:
				first_jump_order = Time.get_ticks_msec()
			if Time.get_ticks_msec() - first_jump_order > JUMP_DELAY:
				jump()
				first_jump_order = -1
		else:
			first_jump_order = -1
		# Target is down and we are jumping so stop jump motion
		if desired_velocity.y > 0 and velocity.y < 0:
			# velocity.y = 0
			pass
		current_state = STATE.RUN
	
	print("Velocity is: " + str(velocity.x))
	if current_state != STATE.HIT and is_zero_approx(velocity.x):
		current_state = STATE.IDLE
	
	move_and_slide()


func actor_setup():
	await get_tree().physics_frame
	if TARGET:
		$NavigationAgent2D.target_position = TARGET.global_position


var bullet_count = 0
func bullet_hit(bullet: RigidBody2D):
	# If dead don't do anything
	if current_state == STATE.DEAD:
		return
	
	# Handle health
	current_health -= 4
	if current_health < 0:
		current_health = 0
	
	if current_health <= 0:
		die()
	bullet.queue_free()


func die():
	died.emit(self)
	current_state = STATE.DEAD
	$AnimatedSprite2D.play("death")
	$CollisionShape2D.set_deferred("disabled", true)


# Reached target, attack
func _on_navigation_agent_2d_target_reached():
	current_state = STATE.HIT


func attack():
	# Swing weapon and check if character is in it
	var bodies = $SwingArea.get_overlapping_bodies()
	for body in bodies:
		if body == TARGET:
			# Hit the target
			if body.has_method("got_hit"):
				body.got_hit()


# Only call in physics frames
func jump():
	if is_on_floor():
		velocity.y += JUMP_SCALE
	
	
func _on_animated_sprite_2d_frame_changed():
	if current_state == STATE.HIT and ($AnimatedSprite2D.get_frame() == 4 or $AnimatedSprite2D.get_frame() == 11):
		# Weapon swing frame
		attack()
	elif current_state == STATE.DEAD and $AnimatedSprite2D.get_frame() == 5:
		# End of death animation, stop
		$AnimatedSprite2D.pause()
