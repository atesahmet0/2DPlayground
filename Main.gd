extends Node

@export var spawn_enemies: bool = false

var flying_eye_dead_effect_scene = preload("res://Scenes/FlyingEyeDeadBlood.tscn")
var flying_eye_scene = preload("res://Scenes/FlyingEye.tscn")
var flying_eye_script = preload("res://Scenes/FlyingEye.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_enemy_spawn_timer_timeout():
	if not spawn_enemies:
		return
	
	# Spawn enemy in random position.
	var enemy_positon = $FlyingEyeSpawnBox.global_position
	var enemy = flying_eye_scene.instantiate()
	
	# Setup enemy
	enemy.position = enemy_positon
	enemy.set_target($Player)
	enemy.connect("died", _on_flying_eye_died)
	var scale = randf_range(1.5, 2.5)
	enemy.scale = Vector2(scale, scale)
	add_child(enemy)

func _on_flying_eye_died(object):
	var scene = flying_eye_dead_effect_scene.instantiate()
	scene.start(object.position)
	get_parent().add_child(scene)
