extends Node

var player_data
var lore_data

var scene_to_change_to
var is_loading = false

func _ready():
	#get lore data
	var file = FileAccess.open("res://lore/lore.json", FileAccess.READ)
	lore_data = JSON.parse_string(file.get_as_text())
	file.close()
	load_default_player_data()
	
	# check if save directory exists
	var dir = DirAccess.open("user://")
	if not dir.dir_exists('saves'):
		dir.make_dir('saves')

func load_default_player_data():
	# get player data (default one in lore file)
	var file = FileAccess.open("res://lore/lore.json", FileAccess.READ)
	player_data = JSON.parse_string(file.get_as_text())['character']
	file.close()

func load_player_data(path):
	var file = FileAccess.open(path, FileAccess.READ)
	player_data = JSON.parse_string(file.get_as_text())
	file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# useful function for searching through a list of json documents 
# and retrieving the value for a key for a document that has a certain id
func searchDocsInList(list, uniquekey: String, uniqueid: String, key: String):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			if key in doc.keys():
				return doc[key]
			else:
				return null
	return null

# useful function for searching through a list of json documents
# and retrieving doc where there is a certain value for a certain key
func returnDocInList(list, uniquekey, uniqueid):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			return doc
	return null
	
# useful function for making an array unique
func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

#useful function for picking a random value from a list
func choose_random_from_list(rand_list):
	return rand_list[randi() % rand_list.size()]

#useful function for returning a list of files in a directory
func dir_contents(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("Found directory: " + file_name)
				pass
			else:
				if file_name.find('.import') == -1:
					#print("Found file: " + file_name)
					files.append(file_name)
			file_name = dir.get_next()
	else:
		#print("An error occurred when trying to access the path.")
		pass
	return files
