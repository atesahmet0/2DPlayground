extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start(new_position: Vector2, direction: Vector2 = Vector2.DOWN):
	position = new_position
	look_at(direction)
	restart()



func _on_finished():
	queue_free()
