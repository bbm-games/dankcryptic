extends Node2D
var tabs
var hoverSound 
var lore_data

# Called when the node enters the scene tree for the first time.
func _ready():
	tabs = get_node("TabContainer")
	
	# add sound effects to all buttons on hover
	hoverSound = get_node("hoverSound")
	connect_buttons(get_tree().root)
	get_tree().node_added.connect(_on_SceneTree_node_added)
	
	# read in JSON and go from there
	var file = FileAccess.open("lore/lore.json", FileAccess.READ)
	lore_data = JSON.new().parse_string(file.get_as_text())
	file.close()
	
	# load in class buttons and base stats
	var classes = tabs.get_node("Vocation").get_node("HBoxContainer").get_node("GridContainer")
	for button in classes.get_children():
		var vocation_name = button.get_text()
		var vocation_data = get_vocation_stats(button.get_text())
		# make it so stats UI updates on the button click
		button.pressed.connect(vocation_button_pressed.bind(vocation_name))
	
func vocation_button_pressed(vocation_name):
	print(vocation_name)
	# display stat data for the vocation
	var statsdatajson = get_vocation_stats(vocation_name)
	var statvalues = tabs.get_node("Vocation/HBoxContainer/VBoxContainer3/HBoxContainer2/VBoxContainer2").get_children()
	var statlabels = tabs.get_node("Vocation/HBoxContainer/VBoxContainer3/HBoxContainer2/VBoxContainer").get_children()
	var i = 0
	for statvalue in statvalues:
		statvalue.set_text(str(statsdatajson['stats'][statlabels[i].get_text().to_lower()]))
		i += 1
	# display lore description too
	self.get_node("TabContainer/Vocation/HBoxContainer/RichTextLabel").set_text(statsdatajson['lore'])
func get_vocation_stats(name):
	for thing in lore_data["vocations"]:
		if thing["class_name"] == name:
			return thing
	return "Couldn't find vocation data for " + name
	
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

func _on_char_name_line_edit_text_changed(new_text):
	get_node("TabContainer/Confirm/VBoxContainer/HBoxContainer/Label").set_text(new_text)
