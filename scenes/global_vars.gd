extends Node

var player_data
var lore_data

func _ready():
	#get lore data
	var file = FileAccess.open("res://lore/lore.json", FileAccess.READ)
	lore_data = JSON.parse_string(file.get_as_text())
	file.close()
	# get player data (default one in lore file)
	file = FileAccess.open("res://lore/lore.json", FileAccess.READ)
	player_data = JSON.parse_string(file.get_as_text())['character']
	file.close()

func load_player_data(path):
	var file = FileAccess.open(path, FileAccess.READ)
	player_data = JSON.parse_string(file.get_as_text())
	file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
