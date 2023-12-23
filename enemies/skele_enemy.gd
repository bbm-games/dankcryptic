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

var flipDelayTimer = 0

var health_bar
var health_bar_height
var health_bar_length

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

var enemy_data = GlobalVars.returnDocInList(GlobalVars.lore_data['enemies'],'name', 'Skele').duplicate(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	
	rng = RandomNumberGenerator.new()
	
	# initial state when spawned is idle
	self.changeState(States.IDLE)
	
	vel = Vector2(0,0)
	
	health_bar = get_node("health_bar/healthBar")
	health_bar_length= health_bar.get_size().x
	health_bar_height = health_bar.get_size().y

func changeState(state_name):
	if current_state != state_name:
		current_state = state_name
	main_game_node.chatBoxAppend(StateStrings[state_name])
	if current_state == States.ATTACK:
		self.showCertainSprite(States.ATTACK)		
	else:
		pass
	if current_state == States.IDLE:
		self.showCertainSprite(States.IDLE)
	if current_state == States.WALK:
		self.showCertainSprite(States.WALK)
		speed = base_speed
	if current_state == States.WALKFAST:
		# TODO: modify the walk fast state sprite
		self.showCertainSprite(States.WALK)
		speed = base_speed * 2
	if current_state == States.DEATH:
		self.showCertainSprite(States.IDLE)
		speed = 0

func showCertainSprite(enum_given):
	var name_given : String = StateStrings[enum_given]
	# by default the hit box should not be active when a state changes
	get_node('hitBox').set_monitoring(false)
	if not get_node(name_given).is_visible():
		for child in get_children():
			if child is Sprite2D:
				child.hide()
		get_node(name_given).show()
		get_node('AnimationPlayer').play(name_given)	
		if enum_given == States.WALKFAST:
			get_node('AnimationPlayer').set_speed_scale(2)
		else:
			get_node('AnimationPlayer').set_speed_scale(1)

func flip_sprite():
	pass

func take_damage(value, _statusInflictions = null, ranged = false):
	if current_state != States.DEATH: # let's not retween death animation if already dead
		get_node('clapped_sound').play()
		just_took_damage = true
		enemy_data['current_health'] -= value
		if enemy_data['current_health'] <= 0:
			enemy_data['current_health'] = 0
			# add the material for shader pixel explosion
			var to_dust = preload('res://materials/to_dust.tres')
			changeState(States.DEATH)
			# TODO: actually have a death sprite to attach the to_dust material to
			get_node('idle').set_material(to_dust)
			get_node('attack').set_material(to_dust)
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
			
func dropItems():
	for itemid in self.enemy_data['inventory']:
		# TODO: Make it to items have droprates
		var item = preload("res://objects/ground_item.tscn")
		var item_instance = item.instantiate()
		main_game_node.get_node('currentMap/Node2D').add_child(item_instance)
		item_instance.load_item(itemid)
		item_instance.position = self.get_position()  + Vector2(rng.randi_range(-5,5), rng.randi_range(-5,5))

	# drop some coins too
	for i in range(rng.randi_range(20,50)):
		var item = preload("res://objects/gold_piece.tscn")
		var item_instance = item.instantiate()
		main_game_node.get_node('currentMap/Node2D').add_child(item_instance)
		item_instance.position = self.get_position() + Vector2(rng.randi_range(-50,50), rng.randi_range(-50,50))

func on_tween_finished():
	
	# drop its rewards
	dropItems()
	
	# delete the skele
	queue_free()

func set_to_dust_sensitivity(value: float):
	get_node('idle').get_material().set_shader_parameter('sensitivity', value)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# update the health bar
	health_bar.set_size(Vector2(enemy_data['current_health']/enemy_data['max_health'] * health_bar_length, health_bar_height))
	
	# display red damage color
	if just_took_damage:
		damage_highlight_time += delta
		self.set_modulate(Color(1,.16,.16,1))
		if damage_highlight_time > .3:
			damage_highlight_time = 0
			just_took_damage = false
			
	else:
		self.set_modulate(base_modulation)
		
	# flips the skele sprite to face the target_body at all times
	flipDelayTimer += delta
	if target_body:
		if (target_body.position - self.position).x < 0 and flipDelayTimer > 1:
			flipDelayTimer = 0
			self.set_transform(Transform2D(Vector2(-1.5, 0), Vector2(0,  1.5), Vector2(position.x, position.y)))
			offset = Vector2(-13,0)
			# flip back the health bar
			get_node("health_bar").set_transform(Transform2D(Vector2(-1, 0), Vector2(0,  1), get_node('health_bar').position))
		elif flipDelayTimer > 1:
			# unflip
			flipDelayTimer = 0
			offset = Vector2(13,0)
			self.set_transform(Transform2D(Vector2(1.5, 0), Vector2(0,  1.5), Vector2(position.x, position.y)))
			# flip back the health bar
			get_node("health_bar").set_transform(Transform2D(Vector2(1, 0), Vector2(0,  1), get_node('health_bar').position))
	# makes the skele move to target body if in the WALK or WALK_FAST STATE
	if (current_state == States.WALK or current_state == States.WALKFAST) and target_body:
		# with steering
		#des_vel = (target_body.position + offset - (get_node('attackZone').position + self.position)).normalized() * speed
		#var steering = (des_vel - vel) / mass
		#vel += steering
		#self.move_and_collide(vel * delta)
		
		# without steering
		self.move_and_collide((target_body.position + offset - (get_node('attackZone').position + self.position)).normalized() * speed * delta)
		
	# limits the WALKFAST state TO 5 seconds
	if current_state == States.WALKFAST:
		walk_fast_time += delta
		if walk_fast_time > 5:
			changeState(States.WALK)
			walk_fast_time = 0

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
		#await get_tree().create_timer(1.0).timeout
		changeState(States.ATTACK)
		
func _on_attack_zone_body_exited(body):
	if body == target_body:
		changeState(States.WALKFAST)
