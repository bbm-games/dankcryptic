extends CanvasLayer

var player;

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("AnimationPlayer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_area_2d_mouse_entered():
	player.play("fade in hud")


func _on_area_2d_mouse_exited():
	player = get_node("AnimationPlayer")
	player.play("fade out hud")
