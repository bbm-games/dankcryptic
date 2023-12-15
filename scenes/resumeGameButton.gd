extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_mouse_entered():
	self.grab_focus() # Replace with function body.


func _on_button_mouse_entered():
	get_parent().get_node('Button').grab_focus() # Replace with function body.


func _on_button_2_mouse_entered():
	get_parent().get_node('Button2').grab_focus()


func _on_button_3_mouse_entered():
	get_parent().get_node('Button3').grab_focus()
