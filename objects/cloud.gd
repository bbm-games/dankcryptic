extends "res://objects/projectile.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 5
	lifetime_limit = 10
	main_game_node = get_tree().get_root().get_node('Node2D')
	rng = RandomNumberGenerator.new()
	
	# TODO: GENERALIZE THIS SO YOU GRAB THE MAGIC LEVEL FROM WHOEVER THE CASTER IS
	magic_level = GlobalVars.player_data['stats']['magic'] 
	
	# play the projectile trails if need be
	get_node('GPUParticles2D').set_emitting(true)
	
	# play the spawn sound for the fireball
	# TODO: set the stream so it's consistent with the type of projectile this is
	get_node('spawnSound').play()
	
	spell_inflictions = {
		"poisoned":0.02,
		"burned":0.0,
		"drenched":0.0,
		"confused":0.0,
		"paralyzed":0.0,
		"bloodless":0.0
	}

func flicker(energy_range = 0.05):
	get_node("PointLight2D").set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
	get_node("PointLight2D").energy = 0.33 + rng.randf_range(-1*energy_range,energy_range)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# delete the projectile if it's gone on past it's lifetime
	lifetime_counter += delta
	if lifetime_counter >= lifetime_limit:
		queue_free()
	
	# flicker the light
	flicker()	
	
	# move the projectile in the direction it's facing
	#direction_facing_vector = Vector2.RIGHT.rotated(self.get_global_rotation())
	self.set_position(self.get_position() + direction_facing_vector * delta * speed)
	
	# apply damage if in cloud
	var bodies = self.get_overlapping_bodies();
	if bodies:
		for body in bodies:
			if body.is_attackable:
				if body.has_method("take_damage"):
					# calculate the difference between caster magic and enemy defense to determine critical hit percentage
					var diff
					if "is_player" in body:
						if body.is_player == true:
							diff = magic_level - GlobalVars.player_data['stats']['defense']
					else:
						diff = magic_level - body.enemy_data['stats']['defense']
					var prob = 0
					if diff <= 0: # if the enemy is higher level than you, you cannot critically hit
						prob = 0
					else:
						# base critical hit change at same level is 1/10
						prob = 0.1 + pow(2.718,-10/diff) * 0.9
					spell_inflictions['poisoned'] = 0.2 * delta
					if rng.randf_range(0,1) <= prob:
						# then do a critical hit
						body.take_damage(magic_level/5.0 * delta, spell_inflictions, false, true)
						#get_node('player/criticalSoundPlayer').play()
					else:
						# do a normal hit
						body.take_damage(magic_level/10.0 * delta, spell_inflictions, false, true)
						#get_node('player/attackSoundPlayer').play()		
