extends Node2D
var player
var optionsMenu
var light
var rng
var backgroundMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	player = get_node("uiPlayer")
	light = get_node('spotlight')
	backgroundMusic = get_node("/root/Music")
	if backgroundMusic.stream:
		var filemusic = backgroundMusic.stream.resource_path.get_file()
		if filemusic != '1- Midnight Dreams.mp3':
			backgroundMusic.stream = load('res://assets/music/mindseyepack/1- Midnight Dreams.mp3')
			backgroundMusic.play()
	
	# load in the options menu
	var options_resource = ResourceLoader.load("res://scenes/options.tscn")
	var options_scene = options_resource.instantiate()
	optionsMenu = get_node("CanvasLayer2/options")
	optionsMenu.add_child(options_scene)
	optionsMenu.get_node("Node2D/CanvasLayer").hide()

func _input(event):
	if event is InputEventMouseMotion:
		#show the mouse if it was hiding
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# add flicker to spotlight
	#light.set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.1,.1), rng.randf_range(-.1,.1)))
	if rng.randf_range(0,1) < 0.2:	
		light.energy = 0.4 + rng.randf_range(-0.2,0.2)

func startNewGame():
	# TODO: actually create character creation
	get_tree().change_scene_to_file("res://scenes/creation.tscn")

# exit button
func _on_link_button_4_pressed():
	get_tree().quit()

# new game button
func _on_link_button_pressed():
	startNewGame()

func _on_link_button_2_mouse_entered():
	get_node("%LinkButton2").grab_focus()
	player.play()

func _on_link_button_3_mouse_entered():
	get_node("%LinkButton3").grab_focus()
	player.play()

func _on_link_button_4_mouse_entered():
	get_node("%LinkButton4").grab_focus()
	player.play()

func _on_new_game_button_mouse_entered():
	get_node("%newGameButton").grab_focus() 
	player.play()

func _on_link_button_3_pressed():
	optionsMenu.get_node("Node2D/CanvasLayer").show()
	
# load game button
func _on_link_button_2_pressed():
	# TODO: eventually take to a load saves screen
	# for now it's just a file picker
	get_node("CanvasLayer/FileDialog").show()

# if a save file is confirmed to be opened
func _on_file_dialog_confirmed():
	var path = get_node("CanvasLayer/FileDialog").get_current_path()
	# establish the new player save file
	GlobalVars.load_player_data("res://saves/" + path)
	# start the game and set the location of the save file
	get_tree().change_scene_to_file("res://scenes/game.tscn")
