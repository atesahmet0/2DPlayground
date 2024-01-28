extends Control

signal start_clicked
signal exit_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_start_gui_input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == 1):
		start_clicked.emit()

func _on_exit_gui_input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == 1):
		exit_clicked.emit()
