extends Button
var time_paused = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	time_paused += delta
	if Input.is_action_just_pressed("pause") and time_paused >= 0.25:
		if get_tree().paused:
			print("unpausing")
			get_parent().hide()
			time_paused = 0.0
			get_tree().paused = false

func _on_mouse_entered():
	self.grab_focus() # Replace with function body.


func _on_button_mouse_entered():
	get_parent().get_node('Button').grab_focus() # Replace with function body.


func _on_button_2_mouse_entered():
	get_parent().get_node('Button2').grab_focus()


func _on_button_3_mouse_entered():
	get_parent().get_node('Button3').grab_focus()
