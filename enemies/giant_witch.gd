extends CharacterBody2D

var main_game_node # contains the root of the entire game
var target_body = null # will be the body that will be targeted
var offset : Vector2   # contains offset to the target_body_position that enemy will move to
var base_speed = 30 # incorporated delta scaling factor
var speed = base_speed

var des_vel : Vector2 # the desired velocity (used in steering)
var vel : Vector2 
var mass : float = 1

var current_state # holds the current state in the state machine
var walk_fast_time = 0 # a counter variable used for limiting how long the skele can chase you
var is_attackable = true
var just_took_damage = false 
var damage_highlight_time = 0
var base_modulation = self.get_modulate()

var attackCooldown = 0

var rng
# the enemy states
enum States{
	IDLE,
	ATTACK,
	WALK,
	WALKFAST,
	DEATH
}

var StateStrings = {
	States.IDLE: 'idle',
	States.WALK: 'walk',
	States.WALKFAST: 'walkfast',
	States.ATTACK: 'attack',
	States.DEATH: 'death'
}

var enemy_data =  {"stats":{
			"attack":65,
			"defense":65,
			"strength":20,
			"health":90,
			"stamina":100,
			"magic":40,
			"wisdom":60,
			"mana":40
		 }}
# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	
	rng = RandomNumberGenerator.new()
	
	# initial state when spawned is idle
	self.changeState(States.IDLE)
	
	vel = Vector2(0,0)

func changeState(state_name):
	if current_state != state_name:
		# wait 5 seconds before changing state
		#await get_tree().create_timer(0.5).timeout
		current_state = state_name
	main_game_node.chatBoxAppend(StateStrings[state_name])
	if current_state == States.ATTACK:
		# there is no attack sprite atm
		if target_body:
			facePlayer(true)
		self.showCertainSprite(States.IDLE)
	if current_state == States.IDLE:
		if target_body:
			facePlayer(true)
		self.showCertainSprite(States.IDLE)
	if current_state == States.WALK:
		if target_body:
			facePlayer(true)
		self.showCertainSprite(States.WALK)
		speed = base_speed
	if current_state == States.WALKFAST:
		if target_body:
			facePlayer(true)
		# TODO: modify the walk fast state sprite
		self.showCertainSprite(States.WALKFAST)
		speed = base_speed * 2
	if current_state == States.DEATH:
		self.showCertainSprite(States.IDLE)
		speed = 0

func showCertainSprite(enum_given):
	var name_given : String = StateStrings[enum_given]
	# by default the hit box should not be active when a state changes
	# get_node('hitBox').set_monitoring(false)
	
	# hide all current sprites
	for child in get_children():
		if child is Sprite2D:
			child.hide()
	
	if enum_given == States.IDLE:
		get_node(name_given).show()
	else:
		# for walk and walkfast states
		if enum_given == States.WALKFAST:
			get_node('AnimationPlayer').set_speed_scale(2)
			get_node(StateStrings[States.WALKFAST]).show()
			#get_node(StateStrings[States.WALK]).hide()
		elif enum_given == States.WALK:
			get_node('AnimationPlayer').set_speed_scale(1)
			#get_node(StateStrings[States.WALKFAST]).hide()
			get_node(StateStrings[States.WALK]).show()

func take_damage(value, _statusInflictions = null, ranged = false):
	if current_state != States.DEATH: # let's not retween death animation if already dead
		get_node('clapped_sound').play()
		just_took_damage = true
		enemy_data['stats']['health'] -= value
		if enemy_data['stats']['health'] <= 0:
			enemy_data['stats']['health'] = 0
			# add the material for shader pixel explosion
			var to_dust = preload('res://materials/to_dust.tres')
			changeState(States.DEATH)
			# TODO: actually have a death sprite to attach the to_dust material to
			get_node('idle').set_material(to_dust)
			get_node('walkfast').set_material(to_dust)
			get_node('walk').set_material(to_dust)
			var tween = get_tree().create_tween()
			tween.tween_method(set_to_dust_sensitivity, 0.0, 1.0, 1)
			tween.connect("finished", on_tween_finished)
		#TODO: apply status inflictions to enemy
		
		# if the skele was idling with no target and got blasted by a range attack
		if current_state == States.IDLE and not target_body:
			main_game_node.chatBoxAppend('Attacked by unknown ranger!')
			# adjust the base speed
			base_speed *= 2
			changeState(States.WALKFAST)
			# double the detection zone to find the player!
			var circleshape = get_node('detectionZone/CollisionShape2D').get_shape()
			circleshape.set_radius(circleshape.get_radius()*2)
		
		if ranged and target_body:
			changeState(States.WALKFAST)
			

func on_tween_finished():
	queue_free()

func set_to_dust_sensitivity(value: float):
	# remmeber shader is shared across the sprites, so only need to adjust on one sprite
	get_node('idle').get_material().set_shader_parameter('sensitivity', value)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# display red damage color
	if just_took_damage:
		damage_highlight_time += delta
		self.set_modulate(Color(1,.16,.16,1))
		if damage_highlight_time > .3:
			damage_highlight_time = 0
			just_took_damage = false
			
	else:
		self.set_modulate(base_modulation)
	
	if target_body:
		facePlayer()
	
	# makes the skele move to target body with appropraite sprite if in the WALK or WALK_FAST STATE
	if (current_state == States.WALK or current_state == States.WALKFAST) and target_body:	
		# with steering
		des_vel = (target_body.position + offset - (get_node('attackZone').position + self.position)).normalized() * speed
		var steering = (des_vel - vel) / mass
		vel += steering
		self.move_and_collide(vel * delta)
		
		# without steering
		#self.move_and_collide((target_body.position + offset - (get_node('attackZone').position + self.position)).normalized() * speed * delta)
	
	# limits the WALKFAST state TO 5 seconds
	if current_state == States.WALKFAST:
		walk_fast_time += delta
		if walk_fast_time > 5:
			changeState(States.WALK)
			walk_fast_time = 0
			
# this function makes the animationplayer play the proper animation.
# if it's specified do be done instantly then the player will not wait until the previous animation is 
# complete to start playing the next one. This is useful when changing states, as that results 
# in changing sprites, and you don't want a new sprite to show while the animation of the previous sprite is finishing.

func facePlayer(instant: bool = false):
	var direction_to_player = (target_body.get_position() - self.get_position()).normalized()
	if (current_state == States.WALK or current_state == States.WALKFAST) and target_body:
		if direction_to_player.x > 0 and abs(direction_to_player.y)  < abs(direction_to_player.x):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_right')
			else:
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_right')	
			offset = Vector2(-13,0)
		if direction_to_player.x < 0 and abs(direction_to_player.y)  < abs(direction_to_player.x):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_left')	
			else:
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_left')	
			offset = Vector2(13,0)
		if direction_to_player.y > 0 and abs(direction_to_player.x)  < abs(direction_to_player.y):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_down')	
			else:
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_down')	
		if direction_to_player.y < 0 and abs(direction_to_player.x)  < abs(direction_to_player.y):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_up')	
			else:
				get_node('AnimationPlayer').play(StateStrings[current_state] + '_up')	
	
	elif (current_state == States.ATTACK or current_state == States.IDLE) and target_body:
		if direction_to_player.x > 0 and abs(direction_to_player.y)  < abs(direction_to_player.x):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_right')	
			else:
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_right')	
			offset = Vector2(-13,0)
		if direction_to_player.x < 0 and abs(direction_to_player.y)  < abs(direction_to_player.x):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_left')	
			else:
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_left')	
			offset = Vector2(13,0)
		if direction_to_player.y > 0 and abs(direction_to_player.x)  < abs(direction_to_player.y):
			if not (get_node('AnimationPlayer').is_playing() or instant):
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_down')	
			else:
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_down')
		if direction_to_player.y < 0 and abs(direction_to_player.x)  < abs(direction_to_player.y):
			if not get_node('AnimationPlayer').is_playing():
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_up')	
			else:
				get_node('AnimationPlayer').play(StateStrings[States.IDLE] + '_up')	
				
func applyShake(shake_strength_given = 5):
	main_game_node.apply_shake(shake_strength_given)
	
func _physics_process(_delta):
	pass

func attack_a_body(body):
	#main_game_node.chatBoxAppend(str(body))
	# attack the body
	if body.has_method("take_damage"):
		var diff = enemy_data['stats']['attack'] - GlobalVars.player_data['stats']['defense']
		var prob = 0.1 + pow(2.718,-10/diff) * 0.9
		if rng.randf_range(0,1) <= prob:
			# damage is strength times 2 if critical hit
			body.take_damage(enemy_data['stats']['strength']*2)
		else:
			# normal hit
			body.take_damage(enemy_data['stats']['strength'])
			
	#main_game_node.chatBoxAppend('got clapped')

func _on_hit_box_body_entered(body):
	self.attack_a_body(body)
	
func _on_hit_box_body_exited(_body):
	pass

func _on_detection_zone_body_entered(body):
	# basically targets any body that can take damage (this includes player)
	if body.has_method("take_damage") and body.is_player:
		target_body = body
		if current_state == States.WALKFAST:
			pass
		else:
			changeState(States.WALK)
	
func _on_detection_zone_body_exited(body):
	if body == target_body:
		target_body = null
	changeState(States.IDLE)
	
func _on_attack_zone_body_entered(body):
	if body == target_body and current_state != States.WALKFAST:
		changeState(States.ATTACK)	
	elif body == target_body:
		
		changeState(States.ATTACK)
		
		
func _on_attack_zone_body_exited(body):
	# chase after the player 
	if body == target_body:
		await get_tree().create_timer(0.2).timeout
		changeState(States.WALKFAST)

