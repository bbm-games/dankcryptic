extends Node2D
var backgroundMusic 

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("AnimationPlayer")
	backgroundMusic = get_node("/root/Music")
	player.connect("animation_finished", openGameMenu)
	backgroundMusic.stream = load('res://assets/music/mindseyepack/1- Midnight Dreams.mp3')
	backgroundMusic.play()

func openGameMenu(_arg):
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
