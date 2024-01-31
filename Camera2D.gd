extends Camera2D

signal moved(camera: Camera2D)

@export var playerNode2D: Node2D
@export var thresholdY: float = 600

@export_category("Camera Shake")
# Do not change this on runtime. Results will be unpredictable
@export var SHAKE_ON_WEAPON_FIRE: bool = true
@export var DECAY = 4  # How quickly the shaking stops [0, 1].
@export var MAX_OFFSET = Vector2(5, 10)  # Maximum hor/ver shake in pixels.
@export var MAX_ROLL: float = 0.5  # Maximum rotation in radians (use sparingly).
@export var TRAUMA = 1.60
# Exponent
@export var TRAUMA_POWER = 2

var trauma = 0

func _ready():
	# I don't know what is this. I guess it is useless.
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.x < playerNode2D.position.x:
		position.x = playerNode2D.position.x
		moved.emit(self)
		align()
	
	if trauma and SHAKE_ON_WEAPON_FIRE:
		trauma = max(trauma - DECAY * delta, 0)
		shake()


func shake():
	var amount = pow(trauma, TRAUMA_POWER)
	rotation = MAX_ROLL * amount * randf_range(-1, 1)
	offset.x = MAX_OFFSET.x * amount * randf_range(-1, 1)
	offset.y = MAX_OFFSET.y * amount * randf_range(-1, 1)


func _on_shotgun_weapon_fired(current_ammo: int):
	trauma = TRAUMA

