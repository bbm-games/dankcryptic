extends Node2D

var map_name = "Badlands - Dank Cellar"
var map_music = "res://assets/music/mindseyepack/3- Something's wrong.mp3"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# THIS CODE SHOWS HOW TO LOAD IN AN ITEM:
	var item = preload("res://objects/ground_item.tscn")
	var item_instance = item.instantiate()
	self.add_child(item_instance)
	item_instance.load_item('weapon8')
	item_instance.position = get_node('treasure').position
	
	# THIS CODE SHOWS HOW TO LOAD IN AN ITEM:
	item = preload("res://objects/ground_item.tscn")
	item_instance = item.instantiate()
	self.add_child(item_instance)
	item_instance.load_item('weapon2')
	item_instance.position = get_node('treasure2').position
	
	# The other way to load in item
	get_node('treasure3').load_item('weapon13')
	
	# The other way to load in item
	get_node('treasure4').load_item('armor006')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
