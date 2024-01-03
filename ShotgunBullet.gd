extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	for i in get_colliding_bodies():
		if i.has_method("bullet_hit"):
			i.bullet_hit(self)

func start(new_position, look_at_position, new_linear_velocity):
	position = new_position
	look_at(look_at_position)
	$AnimatedSprite2D.play("default")
	linear_velocity = new_linear_velocity

func delete_after(time: float = 0):
	await get_tree().create_timer(time).timeout
	_delete()

func _delete():
	print("delete called")
	queue_free()
