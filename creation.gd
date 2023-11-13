extends Node2D
var tabs
var hoverSound 

# Called when the node enters the scene tree for the first time.
func _ready():
	tabs = get_node("TabContainer")
	hoverSound = get_node("hoverSound")
	connect_buttons(get_tree().root)
	get_tree().node_added.connect(_on_SceneTree_node_added)

func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)
		
# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(button):
	button.mouse_entered.connect(_on_mouse_entered_button)

func _on_mouse_entered_button():
	hoverSound.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_next_button_pressed():
	if (tabs.get_current_tab() + 1 < tabs.get_tab_count()):
		tabs.set_current_tab(tabs.get_current_tab() + 1) 
		
func _on_prev_button_pressed():
	if (tabs.get_current_tab() - 1 >= 0):
		tabs.set_current_tab(tabs.get_current_tab() - 1)

func _on_start_game_button_pressed():
	# start the game
	get_tree().change_scene_to_file("res://game.tscn")
