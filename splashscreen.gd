extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("AnimationPlayer")
	player.connect("animation_finished", openGameMenu)

func openGameMenu(_arg):
	get_tree().change_scene_to_file("res://menu.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
