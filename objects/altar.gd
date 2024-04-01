extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
