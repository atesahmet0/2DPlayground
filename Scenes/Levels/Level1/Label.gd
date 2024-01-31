extends Label

@export var camera: Node
var initial_position: Vector2
var initial_camera_position: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = position
	initial_camera_position = camera.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = initial_position + (camera.position - initial_camera_position)


func _on_shotgun_weapon_fired(current_ammo):
	text = "ammo: " + str(current_ammo)
