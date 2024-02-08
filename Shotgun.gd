extends Node2D

signal weapon_fired(current_ammo: int)

@export var INITIAL_AMMO_COUNT: int = 0
@export_category("Bullet Properties")
# BUllets will be deleted after this.
@export var BULLET_LIFE_TIME: float = 5
# Number of bullets in a single shot
@export var BULLET_COUNT: int = 10
@export var BULLET_MAX_SPEED: float = 2000
@export var BULLET_SPREAD_SCALE: float = 0.125
# A delay between each bullet firing. Preferred is 0. 
@export var DELAY_BETWEEN_BULLETS = 0
@export var BULLET_SPEED_RANDOMNESS: float = 0.8

@export_category("Properties")
@export var SHOTS_PER_MINUTE: int = 60

@export_category("Audio")
# Random audio from list will be played.
@export var GUN_SHOT_AUDIOS = []

@export_category("Recoil")
@export var RECOIL_MAX_DISTANCE_TO_BASE: float = 100
@export var RECOIL_RETURN_SPEED: float = 20
@export var RECOIL_SPEED: float = 100

var bullet_scene = preload("res://ShotgunBullet.tscn")
var shell_scene = preload("res://ShotgunShell.tscn")
var current_ammo: int = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	current_ammo = INITIAL_AMMO_COUNT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	
	# Setup gun smoke and rotation
	var emission_shape_offset = Vector3(90, -15, 0)
	var emission_shape_scale = Vector3(100 * randf_range(0.5, 1), 20 * randf_range(0.6, 1), 0)
	$GPUParticles2D.process_material.emission_shape_scale = emission_shape_scale
	# Fix flip
	if global_position.x - get_global_mouse_position().x > 0:
		# Flip
		$AnimatedSprite2D.flip_v = true
		$GPUParticles2D.rotation = - PI
		$GPUParticles2D.process_material.direction = Vector3(-1, -1, 0)
		emission_shape_offset.x= -emission_shape_offset.x
		$GPUParticles2D.process_material.emission_shape_offset = emission_shape_offset
	else:
		$AnimatedSprite2D.flip_v = false
		$GPUParticles2D.rotation = 0
		$GPUParticles2D.process_material.direction = Vector3(1, -1, 0)
		$GPUParticles2D.process_material.emission_shape_offset = emission_shape_offset	
		
var is_recoiling = false
func _physics_process(delta):
	if Input.is_action_just_pressed("click"):
		# Weapon fired
		fire()
	
	# Handling recoil. Gun always will be back to 0, 0 position
	# Vector from gun to mouse position.
	var direction = (get_global_mouse_position() - get_parent().global_position).normalized()
	
	# Check if is in recoil or not.
	if is_recoiling:
		# Animate recoil    
		if position.length() < RECOIL_MAX_DISTANCE_TO_BASE:
			position += RECOIL_SPEED * -direction * delta
			return
		else:
			is_recoiling = false
	
	# Already at the base.
	if position.is_zero_approx():
		return
	
	# Farther from the base is greater the speed.
	var current_speed = RECOIL_RETURN_SPEED * position.length() / RECOIL_MAX_DISTANCE_TO_BASE
	
	var delta_x = delta * current_speed
	if abs(position.x) < delta_x:
		position.x = 0
	else:
		# Return to original position
		if position.x < 0:
			position.x += delta_x
		else:
			position.x -= delta_x
	
	var delta_y
	
	# Assuring position will be 0 in either directions at the same time.
	# Delta y will be relative to delta_x
	if abs(position.x) > 0 and abs(position.y) > 0:
		delta_y = abs(position.y / position.x * delta_x)
	else:
		delta_y = delta * current_speed
		
	
	if abs(position.y) < delta_y:
		position.y = 0
	else:
		# Return to original position
		if position.y < 0:
			position.y += delta_y
		else:
			position.y -= delta_y
	
	# Recoil is over.
	if position.y == 0 and position.x == 0:
		is_recoiling = false

# As second
var time_between_shots: float = 60 / SHOTS_PER_MINUTE
var last_fire = 0
var can_fire = true

func fire():
	# Check can fire
	if current_ammo <= 0:
		# No ammo left
		return
	if Time.get_ticks_msec() - last_fire < time_between_shots * 100:
		# Not enough time passed since last shot
		return
	
	# Handle fire
	
	last_fire = Time.get_ticks_msec()
	
	# Muzzle animation
	$AnimatedSprite2DMuzzle.play("shoot")
	$AnimatedSprite2DMuzzle.visible = true
	
	# Play audio
	$AudioStreamPlayer2D.stream = GUN_SHOT_AUDIOS[randi() % GUN_SHOT_AUDIOS.size() ]
	$AudioStreamPlayer2D.play()
	
	# Spawn bullets
	for i in range(BULLET_COUNT):
		# Delay between bullets
		if DELAY_BETWEEN_BULLETS != 0:
			await get_tree().create_timer(DELAY_BETWEEN_BULLETS).timeout
		
		var bullet = bullet_scene.instantiate()
		var direction = (get_global_mouse_position() - $Muzzle.global_position).normalized() * BULLET_MAX_SPEED * randf_range(1 - BULLET_SPEED_RANDOMNESS, 1)
		direction = direction.rotated(randf_range(- PI * BULLET_SPREAD_SCALE, PI * BULLET_SPREAD_SCALE))
		# Create a virtual spawn box and spawn bullets inside it
		var location_point = $Muzzle.global_position
		location_point = Vector2(location_point.x + (5 * randf_range(-1, 1)), location_point.y + (5 * randf_range(-1, 1)))
	
		bullet.start(location_point, get_global_mouse_position(), direction)
		# Adding bullet to the list.
		get_parent().get_parent().get_parent().call_deferred("add_child", bullet)
		bullet.call_deferred("delete_after", BULLET_LIFE_TIME)
	
	# Decrease ammo count
	current_ammo -= 1
	
	# Spawn shell
	var shell = shell_scene.instantiate()
	var shell_direction = (get_global_mouse_position() - $Chamber.global_position).normalized()
	var shell_velocity = Vector2(shell_direction.x * 10, shell_direction.y * -20)
	
	shell.position = $Chamber.global_position
	shell.linear_velocity = shell_velocity
	get_parent().get_parent().get_parent().call_deferred("add_child",shell)
	delete_object_after(shell, BULLET_LIFE_TIME)
	
	recoil()
	
	# Barrel smoke
	$GPUParticles2D.restart()
	
	# Signal weapon fire
	weapon_fired.emit(current_ammo)


func recoil():
	# Firing gun while still in recoil gives us wrong directions. So be carefull.
	# move counter mouse position.
	is_recoiling = true

	
func delete_object_after(object: Node2D,time: float):
	await get_tree().create_timer(time).timeout
	object.call_deferred("queue_free")

func _on_animated_sprite_2d_muzzle_animation_looped():
	print("Muzzle animation finished")
	$AnimatedSprite2DMuzzle.stop()
	$AnimatedSprite2DMuzzle.visible = false
