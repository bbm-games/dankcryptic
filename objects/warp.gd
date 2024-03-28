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
				var backgroundMusic = get_node("/root/Music")
				backgroundMusic.stream = preload('res://assets/sounds/RPG_Essentials_Free/12_Player_Movement_SFX/88_Teleport_02.wav')
				backgroundMusic.play()
				main_game_node.changeMap(warp_dest_map)
				
	
