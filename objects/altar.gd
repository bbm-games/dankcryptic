extends RigidBody2D
var main_game_node
var is_altar = true

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# functions to show chat icon when player is in viscinity
func _on_altar_boundary_body_entered(_body):
	get_node('chatIcon').show()
	# play suprise audio
	get_node('surpriseSound').play()

func _on_altar_boundary_body_exited(body):
	get_node('chatIcon').hide()

func save_game():
	# play the save file animation
	main_game_node.get_node('HUDLayer/CanvasGroup/saveIcon').show()
	get_node('saveSound').play()
	# add position and map info and save the current player_data to json
	GlobalVars.player_data['last_map'] = GlobalVars.scene_to_change_to
	GlobalVars.player_data['last_pos_x'] = main_game_node.get_node('player').position.x
	GlobalVars.player_data['last_pos_y'] = main_game_node.get_node('player').position.y
	GlobalVars.save_player_data()
	await get_tree().create_timer(1).timeout
	main_game_node.get_node('HUDLayer/CanvasGroup/saveIcon').hide()
	main_game_node.chatBoxAppend("Saved game.")
