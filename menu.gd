extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startNewGame():
	# TODO: actually create character creation
	get_tree().change_scene_to_file("res://game.tscn")

# exit button
func _on_link_button_4_pressed():
	get_tree().quit()

# new game button
func _on_link_button_pressed():
	startNewGame()



func _on_link_button_2_mouse_entered():
	get_node("LinkButton2").grab_focus()


func _on_link_button_3_mouse_entered():
	get_node("LinkButton3").grab_focus()


func _on_link_button_4_mouse_entered():
	get_node("LinkButton4").grab_focus()
