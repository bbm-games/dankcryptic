extends Node2D

var map_name = "Crumbling Fanum Tax"
var map_music = "res://assets/music/Hodslate Journey Through the Unlight/Monuments Honour a Fallen King.mp3"
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()

func flicker(energy_range = 0.05):
	get_node("PointLight2D").set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
	get_node("PointLight2D2").set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
	get_node("PointLight2D3").set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
	get_node("PointLight2D4").set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
	get_node("PointLight2D").energy = 0.33 + rng.randf_range(-1*energy_range,energy_range)
	get_node("PointLight2D2").energy = 0.33 + rng.randf_range(-1*energy_range,energy_range)
	get_node("PointLight2D3").energy = 0.33 + rng.randf_range(-1*energy_range,energy_range)
	get_node("PointLight2D4").energy = 0.33 + rng.randf_range(-1*energy_range,energy_range)

func _process(_delta):
	flicker()
