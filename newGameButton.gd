extends LinkButton


# Called when the node enters the scene tree for the first time.
func _ready():
	self.grab_focus()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_mouse_entered():
	self.grab_focus() # Replace with function body.
