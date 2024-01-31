extends CharacterBody2D

signal died(object)

enum STATE {RUN, HIT, JUMP, DEAD, IDLE}

@export var HEALTH: int = 100
@export var TARGET: Node2D
@export var SPEED: float = 50
@export var GRAVITY_SCALE: float = 5
@export var JUMP_SCALE: float = 400

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
			pass
		STATE.IDLE:
			$AnimatedSprite2D.play("idle")
		STATE.RUN:
			$AnimatedSprite2D.play("run")
		STATE.HIT:
			$AnimatedSprite2D.play("attack1")
	
	is_flipped = TARGET.global_position.x < global_position.x

	# Handle direction of sprites
	if is_flipped:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
	
	call_deferred("actor_setup")

func _physics_process(delta):
	# If dead don't move
	if current_state == STATE.DEAD:
		return
		
	# Handle direction of physcics objects
	if is_flipped:
		$SwingArea/CollisionShape2D.position.x = -10
	else:
		$SwingArea/CollisionShape2D.position.x = 10

	if not $NavigationAgent2D.is_target_reached():
		var next_path_position = $NavigationAgent2D.get_next_path_position()
		velocity = global_position.direction_to(next_path_position) * SPEED
		current_state = STATE.RUN
	
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_SCALE
	
	move_and_slide()

func jump(delta):
	if is_on_floor():
		# print("jump")
		velocity = Vector2.UP * JUMP_SCALE
	
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


func _on_animated_sprite_2d_frame_changed():
	if current_state == STATE.HIT and $AnimatedSprite2D.get_frame() == 3:
		# Weapon swing frame
		attack()
	
