extends Node

var level1 = preload("res://Scenes/Levels/level_1.tscn")
var current_level: Node = null
var is_game_started = false

func _ready():
	if not is_game_started:
		$MainMenu.set_visible(true)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when start game clicked.
func _on_main_menu_start_clicked():
	# This shouldn't happen. Just in case.
	if is_game_started:
		return
	is_game_started = true
	
	$MainMenu.set_visible(false)
	set_level(level1)

# Exi game.
func _on_main_menu_exit_clicked():
	get_tree().quit()

func _on_character_died():
	set_level(level1)

func set_level(level):
	# Remove current level
	if current_level:
		current_level.queue_free()
	# Create new level
	var new_level = level.instantiate()
	add_child(new_level)
	new_level.character_died.connect(_on_character_died)
	current_level = new_level
