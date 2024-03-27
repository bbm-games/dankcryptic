extends Node2D

var main_game_node
var warp_dest_map

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	
func set_destination(dest: String):
	warp_dest_map = dest
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bodies = get_node('Area2D').get_overlapping_bodies()
	for body in bodies:
		if 'is_player' in body:
			if body.is_player:
				main_game_node.changeMap(warp_dest_map)
				body.set_position(Vector2(576/2, 325/2))
				body.get_node('PlayerAnimationPlayer').stop()
