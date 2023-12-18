extends CharacterBody2D

var main_game_node # contains the root of the entire game
var target_body = null # will be the body that will be targeted
var base_speed = 30 # incorporated delta scaling factor
var speed = base_speed
var current_state # holds the current state in the state machine
var walk_fast_time = 0 # a counter variable used for limiting how long the skele can chase you
var is_attackable = true
var just_took_damage = false 
var damage_highlight_time = 0
var base_modulation = self.get_modulate()
var rng
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
	self.changeState('idle')

func changeState(state_name):
	if current_state != state_name:
		current_state = state_name
	main_game_node.chatBoxAppend(str(state_name))
	if current_state == 'attack':
		self.showCertainSprite('attack')
	else:
		pass
	if current_state == 'idle':
		self.showCertainSprite('idle')
	if current_state == 'walk':
		self.showCertainSprite('walk')
		speed = base_speed
	if current_state == 'walkfast':
		self.showCertainSprite('walk')
		speed = base_speed * 2
	if current_state == 'death':
		self.showCertainSprite('idle')
		speed = 0

func showCertainSprite(name_given):
	# by default the hit box should not be active
	get_node('hitBox').set_monitoring(false)
	if not get_node(name_given).is_visible():
		for child in get_children():
			if child is Sprite2D:
				child.hide()
		get_node(name_given).show()
		get_node('AnimationPlayer').play(name_given)	
		if name_given == 'walkfast':
			get_node('AnimationPlayer').set_speed_scale(2)
		else:
			get_node('AnimationPlayer').set_speed_scale(1)

func flip_sprite():
	pass

func take_damage(value, _statusInflictions = null):
	if current_state != 'death': # let's not retween death animation if already dead
		get_node('clapped_sound').play()
		just_took_damage = true
		enemy_data['stats']['health'] -= value
		if enemy_data['stats']['health'] <= 0:
			enemy_data['stats']['health'] = 0
			# add the material for shader pixel explosion
			var to_dust = preload('res://materials/to_dust.tres')
			changeState('death')
			# TODO: actually have a death sprite to attach the to_dust material to
			get_node('idle').set_material(to_dust)
			var tween = get_tree().create_tween()
			tween.tween_method(set_to_dust_sensitivity, 0.0, 1.0, 1)
			tween.connect("finished", on_tween_finished)
		#TODO: apply status inflictions to enemy

func on_tween_finished():
	queue_free()

func set_to_dust_sensitivity(value: float):
	get_node('idle').get_material().set_shader_parameter('sensitivity', value)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if just_took_damage:
		damage_highlight_time += delta
		self.set_modulate(Color(1,.16,.16,1))
		if damage_highlight_time > .3:
			damage_highlight_time = 0
			just_took_damage = false
	else:
		self.set_modulate(base_modulation)
	if target_body:
		if (target_body.position - self.position).x < 0:
			self.set_transform(Transform2D(Vector2(-1.5, 0), Vector2(0,  1.5), Vector2(position.x, position.y)))
		else:
			# unflip
			self.set_transform(Transform2D(Vector2(1.5, 0), Vector2(0,  1.5), Vector2(position.x, position.y)))
	if current_state == 'walk' or current_state == 'walkfast' and target_body:
		self.move_and_collide((target_body.position - (get_node('attackZone').position + self.position)).normalized() * speed * delta)
	if current_state == 'walkfast':
		walk_fast_time += delta
		if walk_fast_time > 5:
			changeState('walk')
			walk_fast_time = 0
		
func _physics_process(_delta):
	pass

func _on_hit_box_body_entered(body):
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
func _on_hit_box_body_exited(_body):
	pass

func _on_detection_zone_body_entered(body):
	# basically targets any body that can take damage (this includes player)
	if body.has_method("take_damage"):
		target_body = body
		changeState('walk')
		
func _on_detection_zone_body_exited(body):
	if body == target_body:
		target_body = null
	changeState('idle')
	
func _on_attack_zone_body_entered(body):
	if body == target_body and current_state != 'walkfast':
		changeState('attack')
	elif body == target_body:
		await get_tree().create_timer(1.0).timeout
		changeState('attack')
		
func _on_attack_zone_body_exited(body):
	if body == target_body:
		changeState('walkfast')
