extends NavigationRegion2D

@export var tiles: TileMap #Make sure to set as the tilemap you want blocked out

# Called when the node enters the scene tree for the first time.
func _ready():
	var rect = tiles.get_used_rect() #Gets entire region of tilemap
	var used = tiles.get_used_cells(0) #Get the filled in tiles(Mine are in layer 0)
	var all_cells = []
	#interate over all possible tile locations
	for x in range(int(rect.position.x), int(rect.end.x)):
		for y in range(int(rect.position.y), int(rect.end.y)):
			#Combine all possible positions into array
			all_cells.append(Vector2(x, y))
	#Now we want to remove all used cells
	#This leaves us with just the empty areas that we want navigation in
	for cell in used:
		all_cells.erase(Vector2(cell))
	#Now we set the open cells to a clear tile with no collision
	#Make sure navigation is set up on these tiles
	for cell in all_cells:
		tiles.set_cell(1, Vector2i(cell), 1, Vector2i(0, 0), 0) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
