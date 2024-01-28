extends Node

@export var spawn_enemies: bool = false

var flying_eye_dead_effect_scene = preload("res://Scenes/FlyingEyeDeadBlood.tscn")
var flying_eye_scene = preload("res://Scenes/FlyingEye.tscn")
var flying_eye_script = preload("res://Scenes/FlyingEye.gd")
var level1 = preload("res://Scenes/Levels/level_1.tscn")

var is_game_started = false
func _ready():
	if not is_game_started:
		$MainMenu.set_visible(true)
		# $Game.find_child("Camera2D").position = $MainMenu.position + ($MainMenu.size / 2)
		# $Game.find_child("Camera2D").SHAKE_ON_WEAPON_FIRE = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when start game clicked.
func _on_main_menu_start_clicked():
	# This shouldn't happen. Just in case.
	if is_game_started:
		return
	
	is_game_started = true
	# $Game.set_visible(true)
	$MainMenu.set_visible(false)
	var new_level = level1.instantiate()
	add_child(new_level)
	
	# Changing cameras y value to where it belongs.
	# $Game.find_child("Camera2D").position.y = -402 
	# $Game.find_child("Camera2D").SHAKE_ON_WEAPON_FIRE = true



# Exi game.
func _on_main_menu_exit_clicked():
	get_tree().quit()
