extends CharacterBody2D

signal died(object)

@export var HEALTH: int = 100
@export var TARGET: Node2D
@export var SPEED: float = 50
@export var GRAVITY_SCALE: float = 5
@export var JUMP_SCALE: float = 400

@export_category("Momentum")
@export var MOMENTUM_SCALE: float = 200

var hit_blood_scene = preload("res://Scenes/MushroomHitBlood.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_health: float = 0
func _ready():
	current_health = HEALTH

var hit_animation = false
func _process(delta):
	if is_dead:
		return
	
	if is_dying:
		$AnimatedSprite2D.play("dead")
	elif x_momentum > 1 or hit_animation:
		hit_animation = true
		$AnimatedSprite2D.play("take_hit")
	elif velocity.is_zero_approx():
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")
	
	# Handle direction
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	
	call_deferred("actor_setup")

var x_momentum = 0
func _physics_process(delta):
	# If dead don't move
	if is_dead or is_dying:
		return
	
	var next_path_position = $NavigationAgent2D.get_next_path_position()
	
	velocity = global_position.direction_to(next_path_position) * SPEED

	# Handle x momentum
	velocity += -velocity.normalized() * x_momentum * MOMENTUM_SCALE
	x_momentum = 0
	
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
	if is_dying or is_dead:
		return
	
	# Bullet hit. Handle.
	current_health -= 4
	if current_health < 0:
		current_health = 0
	x_momentum += log(bullet.linear_velocity.length())
	if current_health <= 0:
		die()
	bullet.queue_free()
	
	# Set Health Label
	print("RATIO is: " + str(current_health / HEALTH))
	print("Current health is: " + str(current_health) + "\n HEALTH is: " + str(HEALTH))
	var label_text = "%" + str(int((current_health / HEALTH)* 100))
	print(label_text)
	$HealthLabel.text = label_text 
	
	# Add blood particles
	var hit_position = bullet.position
	var hit_velocity = bullet.linear_velocity
	
	var blood = hit_blood_scene.instantiate()
	blood.start(hit_position, hit_velocity)
	get_parent().add_child(blood)

var is_dying = false
var is_dead = false
func die():
	died.emit(self)
	is_dying = true

func _on_animated_sprite_2d_animation_looped():
	hit_animation = false
	if is_dying:
		if not is_dead:
			is_dead = true
			queue_free()

