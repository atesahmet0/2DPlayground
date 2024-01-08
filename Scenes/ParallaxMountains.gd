extends Node2D

@export var NODE_TO_FOLLOW: CharacterBody2D
@export var VELOCITY_SCALE: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var seed: float = 0
func _process(delta):
	seed = NODE_TO_FOLLOW.position.x * VELOCITY_SCALE
	print("seed is:")
	print(seed)
	RenderingServer.global_shader_parameter_set("time_seed", seed)
	
	
