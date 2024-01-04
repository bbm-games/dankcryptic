extends Node2D

var map_name = "Procedural Dungeon"
var map_music = "res://assets/music/Hodslate Journey Through the Unlight/Haunting Ancient Crypts.mp3"
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	
	var item = preload("res://objects/ground_item.tscn")
	var item_instance = item.instantiate()
	self.add_child(item_instance)
	item_instance.load_item('spell007')
	item_instance.position = get_node('spell').position

func _process(_delta):
	pass
