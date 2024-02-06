extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# update the sprite in the background
	#get_node('backgroundimage').set_texture(load())
	var images = GlobalVars.dir_contents('res://assets/loading/')
	get_node('AnimationPlayer').play('modulate fade in')
	get_node('AnimationPlayer').queue('modulate fade out')
	get_node("backgroundimage").set_texture(load('res://assets/loading/' + GlobalVars.choose_random_from_list(images)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if not get_node('AnimationPlayer').is_playing():
	#	get_tree().change_scene_to_file(GlobalVars.scene_to_change_to)
	pass
