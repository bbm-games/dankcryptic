extends CharacterBody2D

var main_game_node

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	showCertainSprite('attack')

func showCertainSprite(name):
	for child in get_children():
		if child is Sprite2D:
			child.hide()
	get_node(name).show()
	get_node('AnimationPlayer').play(name)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	pass


func _on_hit_box_body_entered(body):
	#main_game_node.chatBoxAppend(str(body))
	if body.has_method("take_damage"):
		body.take_damage(20)
	#main_game_node.chatBoxAppend('got clapped')
