extends CharacterBody2D

var main_game_node
var is_player = true
var is_attackable = true

func _init():
	#self.add_collision_exception_with(get_node('hitBox'))
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	
# modifies the player_data anytime damage is taken
func take_damage(damage_val, statusInflictions = null):
	# if the block isn't held then you take true damage
	if not main_game_node.block_held:
		main_game_node.subtractHealth(damage_val)
		main_game_node.apply_shake(15)
		get_node('clappedSoundPlayer').play()
		main_game_node.just_took_damage = true
		# if status inflictions are present apply them fully!
		if statusInflictions:
			for key in statusInflictions:
				GlobalVars.player_data['statuses'][key] += statusInflictions[key]
	else:
		get_node('deflectSoundPlayer').play()
		# deflect all damage if the block is hit in the deflection window
		# also no status effects will be applied!
		if main_game_node.block_held_t_interval < 0.2:
			get_node('sparks').set_emitting(true)
			main_game_node.apply_shake(5)
		else:
			# only partially lose health based on defense level
			# TODO: make this better
			main_game_node.apply_shake(10)
			var frac = damage_val / GlobalVars.player_data['stats']['defense']
			if frac > 1:
				frac = 1
			main_game_node.subtractHealth(int(frac * damage_val))
			main_game_node.just_took_partial_damage = true
			# if status inflictions are present apply them lessed by status negations!
			if statusInflictions:
				for key in statusInflictions:
					var net_amount = statusInflictions[key] - GlobalVars.player_data['statusNegations'][key]
					if net_amount <= 0:
						net_amount = 0
					GlobalVars.player_data['statuses'][key] += net_amount
