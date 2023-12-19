extends Node2D

var map_name = "The Forbidden Sanctum of Desires"
var map_music = "res://assets/music/mindseyepack/7- Eilen.mp3"
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()

func flicker(energy_range = 0.05):
	for light in get_node('lights').get_children():
		light.set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
		light.energy = 0.33 + rng.randf_range(-1*energy_range,energy_range)
	
func _process(delta):
	flicker()
