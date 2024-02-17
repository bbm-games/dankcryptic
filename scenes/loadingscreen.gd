extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# update the game hint text
	get_node('Label').set_text(GlobalVars.choose_random_from_list(GlobalVars.lore_data['hints']))
	# update the sprite in the background
	var images = GlobalVars.dir_contents('res://assets/loading/')
	get_node("backgroundimage").set_texture(load('res://assets/loading/' + GlobalVars.choose_random_from_list(images)))
	get_node('AnimationPlayer').play('modulate fade in')
	
func deleteScreen():
	get_node('AnimationPlayer').play('modulate fade out')
	get_node('AnimationPlayer').queue('colorrect fade out')
	self.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
