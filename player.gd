extends CharacterBody2D

var main_game_node

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')

# modifies the player_data anytime damage is taken
func take_damage(damage_val):
	if not main_game_node.block_held:
		main_game_node.subtractHealth(damage_val)	
		get_node('clappedSoundPlayer').play()
	else:
		get_node('deflectSoundPlayer').play()
		if main_game_node.block_held_t_interval < 0.1: # deflection window
			# deflect all damage
			get_node('sparks').set_emitting(true)
			pass
		else:
			# only partially lose health based on defense level
			# TODO: make this better
			main_game_node.subtractHealth(int(damage_val / GlobalVars.player_data['stats']['defense'] * damage_val))
func _physics_process(delta):
	pass
