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
	if is_dead:
		return
	
	var next_path_position = $NavigationAgent2D.get_next_path_position()
	
	velocity = global_position.direction_to(next_path_position) * SPEED

	# Handle x momentum
	velocity += -velocity.normalized() * x_momentum * MOMENTUM_SCALE
	x_momentum = 0
	
	if not is_on_floor():
		velocity.y += gravity * GRAVITY_SCALE

	var body = move_and_collide(velocity * delta)
	if body:
		jump(delta)
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
	# Bullet hit. Handle.
	bullet_count += 1
	x_momentum += log(bullet.linear_velocity.length())
	print(x_momentum)
	if bullet_count >= HEALTH:
		die()
	bullet.queue_free()
	
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
			await get_tree().create_timer(1).timeout
			queue_free(	)

