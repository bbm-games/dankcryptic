extends Node2D
var player
var optionsMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("uiPlayer")
	# load in the options menu
	var options_resource = ResourceLoader.load("res://options.tscn")
	var options_scene = options_resource.instantiate()
	optionsMenu = get_node("options")
	optionsMenu.add_child(options_scene)
	optionsMenu.get_node("Node2D/CanvasLayer").hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startNewGame():
	# TODO: actually create character creation
	get_tree().change_scene_to_file("res://creation.tscn")

# exit button
func _on_link_button_4_pressed():
	get_tree().quit()

# new game button
func _on_link_button_pressed():
	startNewGame()

func _on_link_button_2_mouse_entered():
	get_node("LinkButton2").grab_focus()
	player.play()

func _on_link_button_3_mouse_entered():
	get_node("LinkButton3").grab_focus()
	player.play()

func _on_link_button_4_mouse_entered():
	get_node("LinkButton4").grab_focus()
	player.play()

func _on_new_game_button_mouse_entered():
	get_node("newGameButton").grab_focus() 
	player.play()

func _on_link_button_3_pressed():
	optionsMenu.get_node("Node2D/CanvasLayer").show()
