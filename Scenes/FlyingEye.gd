extends CharacterBody2D

signal died(object:CharacterBody2D)

@export var SPEED = 300.0
@export var HEALTH: float = 12
var TARGET: Node2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite2D.play("idle")
	
	call_deferred("actor_setup")

func _process(delta):
	if TARGET:
		$NavigationAgent2D.target_position = TARGET.global_position

func _physics_process(_delta):
	if $NavigationAgent2D.is_navigation_finished() or not TARGET:
		move_and_slide()
		return
	
	var next_path_position = $NavigationAgent2D.get_next_path_position()
	
	velocity = global_position.direction_to(next_path_position) * SPEED
	
	move_and_slide()

var bullet_count = 0
func bullet_hit(object: Node2D):
	bullet_count += 1
	if bullet_count >= HEALTH:
		died.emit(self)
		queue_free()
	object.queue_free()
	

func actor_setup():
	# Wait for first physics frame to setup NavigationServer sync
	await get_tree().physics_frame
	
	$NavigationAgent2D.target_position = get_global_mouse_position()

func set_target(target):
	TARGET = target
