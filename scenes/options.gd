extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# exit without saving settings
func _on_button_2_pressed():
	# if the options menu was opened in the main menu
	if get_tree().get_root().get_node_or_null("Menu"):
		get_node("CanvasLayer").hide()
		print('options exited from main menu')
	else:
		# standard exit protocol if options menu is opened in game
		get_node("CanvasLayer").hide()
		get_tree().paused = true
		var pauseMenu = get_tree().get_root().get_node("Node2D/CanvasLayer/pauseMenu")
		pauseMenu.show()
		pauseMenu.get_node('resumeGameButton').grab_focus()
	
# exit with saving settings
func _on_button_pressed():
	#TODO: actually save shit
	# if the options menu was opened in the main menu
	if get_tree().get_root().get_node_or_null("Menu"):
		get_node("CanvasLayer").hide()
		print('options exited from main menu')
	else:
		# standard exit protocol if options menu is opened in game
		get_node("CanvasLayer").hide()
		get_tree().paused = true
		var pauseMenu = get_tree().get_root().get_node("Node2D/CanvasLayer/pauseMenu")
		pauseMenu.show()
		pauseMenu.get_node('resumeGameButton').grab_focus()

# audio settings
func _on_sound_volume_slider_value_changed(value):
	var sounds_bus = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_volume_db(sounds_bus, value)

func _on_master_volume_slider_value_changed(value):
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, value)

func _on_music_volume_slider_value_changed(value):
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, value)


func _on_check_button_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_item_list_item_selected(index):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if index == 0:
		get_window().size = Vector2i(576,324)
	elif index == 1:
		get_window().size = Vector2i(864,486)
	else:
		get_window().size = Vector2i(1152, 648)


func _on_hud_color_picker_color_changed(color):
	# this is how we would save the color to player_data
	#if(GlobalVars.player_data):
	#	GlobalVars.player_data['hud_color'].x = color.r
	#	GlobalVars.player_data['hud_color'].y = color.g
	#	GlobalVars.player_data['hud_color'].z = color.b
		
	if get_tree().get_root().get_node_or_null("Menu"):
		print('options accessed from main menu, will not update HUD colors')
	else:
		# update hud colors if in game
		var main_game_node = get_tree().get_root().get_node('Node2D')
		main_game_node.update_hud_colors(Vector3(color.r, color.g, color.b))
