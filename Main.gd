extends Node

@export var spawn_enemies: bool = false

var flying_eye_dead_effect_scene = preload("res://Scenes/FlyingEyeDeadBlood.tscn")
var flying_eye_scene = preload("res://Scenes/FlyingEye.tscn")
var flying_eye_script = preload("res://Scenes/FlyingEye.gd")

var is_game_started = false
func _ready():
	if not is_game_started:
		$Game.set_visible(false)
		$MainMenu.set_visible(true)
		$Game.find_child("Camera2D").position = $MainMenu.position + ($MainMenu.size / 2)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
