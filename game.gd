extends Node2D

var rng

var player_body
var player_sprite
var light 
var health_bar 
var mana_bar
var stamina_bar
var stamina_bar_length
var stamina_bar_height
var mana_bar_length
var mana_bar_height
var health_bar_length
var health_bar_height

# player data
var player_data

# lore data and stuff derived from it
var lore_data
var all_quick_items

var currentMap
var pauseMenu
var playerMenu
var optionsMenu

var chatBox
var chatPopup

var walk_up_held = false
var walk_down_held = false
var walk_left_held = false
var walk_right_held = false
var block_held = false
var attack_held = false

var time_passed = 0.0
var playerAnimationPlayer
var boss1ScenePath = "res://boss1.tscn"
var dungeonScenePath = "res://dungeon.tscn"
var hoverSound

var item_slot_frame
var item_slot_frame_initial_position
var current_item_index = 0
var dash = false
var base_speed = 0.75
var speed = base_speed

var mouse_event_pos
var emmisionNode
var spell_active

# Called when the node enters the scene tree for the first time.
func _ready():
	
	rng = RandomNumberGenerator.new()
	
	# add hover sound effect to all buttons
	hoverSound = get_node("hoverSound")
	connect_buttons(get_tree().root)
	get_tree().node_added.connect(_on_SceneTree_node_added)
	
	# get pause menu and hide it
	pauseMenu = get_node("CanvasLayer/pauseMenu")
	pauseMenu.hide()
	
	# get player menu and hide it
	playerMenu = get_node("CanvasLayer2/playerMenu")
	playerMenu.hide()
	
	# set up the player
	player_body = get_node("player")
	player_sprite = get_node("player/sprite") 
	light = get_node("player/PointLight2D") 
	emmisionNode = player_body.get_node("GPUParticles2D")
	#map_sprite = get_node("Testbg")
	playerAnimationPlayer = get_node("PlayerAnimationPlayer")
	
	# set up player's health, mana, and stamina
	health_bar = get_node("HUDLayer/CanvasGroup/healthBar")
	stamina_bar = get_node("HUDLayer/CanvasGroup/staminaBar")
	mana_bar = get_node("HUDLayer/CanvasGroup/manaBar")
	stamina_bar_length = stamina_bar.get_size().x
	stamina_bar_height = stamina_bar.get_size().y
	mana_bar_length = mana_bar.get_size().x
	mana_bar_height = mana_bar.get_size().y
	health_bar_length = health_bar.get_size().x
	health_bar_height = health_bar.get_size().y
	
	# Get player and lore data from global variables
	player_data = GlobalVars.player_data
	# TODO: make it seperate from lore.json
	#var file = FileAccess.open("lore/lore.json", FileAccess.READ)
	#player_data = JSON.new().parse_string(file.get_as_text())['character']
	#file.close()
	lore_data = GlobalVars.lore_data
	all_quick_items = lore_data['items'] + lore_data['spells'] + lore_data['quest_items']
	
	# set up the patient's chat box
	chatBox = get_node('HUDLayer/CanvasGroup/chatBox')
	chatBox.append_text("[i]" + player_data.name +" has spawned.[/i]")
	
	# set up the chat box popup for interactions with npcs
	chatPopup = get_node("HUDLayer/chatPopup")
	chatPopup.hide()
	
	# set the textures for the items in the player's quickslots
	# make sure you update the quickslots everytime the player changes shit
	update_quick_slots()
	
	# get the item slot frame
	item_slot_frame = get_node("HUDLayer/CanvasGroup/slotFrame")
	item_slot_frame_initial_position = item_slot_frame.get_position()
	# load in the options menu
	var options_resource = ResourceLoader.load("res://options.tscn")
	var options_scene = options_resource.instantiate()
	optionsMenu = get_node("options")
	optionsMenu.add_child(options_scene)
	optionsMenu.get_node("Node2D/CanvasLayer").hide()
	
	# load in actual game map
	#var scene_resource = ResourceLoader.load(boss1ScenePath)
	var scene_resource = ResourceLoader.load(dungeonScenePath)
	var scene = scene_resource.instantiate()
	currentMap = self.get_node("currentMap")
	currentMap.add_child(scene)

# useful function for searching through a list of json documents 
# and retrieving the value for a key for a document that has a certain id
func searchDocsInList(list, uniquekey, uniqueid, key):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			if key in doc.keys():
				return doc[key]
			else:
				return null
	return null

# updates items in player quick slots
func update_quick_slots():
	for slot in player_data['quick_slots'].keys():
		var item_id = player_data['quick_slots'][slot]
		if item_id:
			var texturepath = searchDocsInList(all_quick_items, "id", item_id, 'sprite_data')
			var itemname = searchDocsInList(all_quick_items, "id", item_id, 'name')
			var itemdesc = searchDocsInList(all_quick_items, "id", item_id, 'description')
			if texturepath:	
				#print(texturepath)
				# draw the item textures in the quickslots
				get_node("%" + slot).set_texture(load(texturepath))
				get_node("%" + slot).set_tooltip_text(itemname + '\n' + itemdesc)
		else:
			# there is not item in the slot
			# clean up the slot
			get_node("%" + slot).texture = null
			get_node("%" + slot).set_tooltip_text("")
func _on_SceneTree_node_added(node):
	if node is Button:
		connect_to_button(node)
		
# recursively connect all buttons
func connect_buttons(root):
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_buttons(child)

func connect_to_button(button):
	button.mouse_entered.connect(_on_mouse_entered_button)

func _on_mouse_entered_button():
	hoverSound.play()
	
func _input(event):
	#print(event.as_text())
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		#print("Mouse Click/Unclick at: ", event.position)
		pass
	elif event is InputEventMouseMotion:
		mouse_event_pos = event.position
	if event.is_action_pressed("item_left"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 0:
			current_item_index = 5
		else:
			current_item_index -= 1
		item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_right"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 5:
			current_item_index = 0
		else:
			current_item_index += 1
		item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_consume"):
		var item_id = player_data['quick_slots']['slot' + str(current_item_index+1)]
		# check to see if item is consumable
		var consumable = searchDocsInList(all_quick_items, 'id', item_id, "is_consumable")
		if consumable:
			# consume whatever current item is active
			var health_replenished = searchDocsInList(all_quick_items, 'id', item_id, "health_replenished")
			var mana_replenished = searchDocsInList(all_quick_items, 'id', item_id, "mana_replenished")
			var stamina_replenished = searchDocsInList(all_quick_items, 'id', item_id, "stamina_replenished") 
			var statusNegations = {}
			statusNegations = searchDocsInList(all_quick_items, 'id', item_id, "statusNegations") 
			player_data['current_health'] += health_replenished
			if health_replenished > 0:
				chatBox.append_text("\nReplenished " + str(health_replenished) + " health.")
			player_data['current_stamina'] += stamina_replenished
			if stamina_replenished > 0:
				chatBox.append_text("\nReplenished " + str(stamina_replenished) + " stamina.")
			player_data['current_mana'] += mana_replenished
			if mana_replenished > 0:
				chatBox.append_text("\nReplenished " + str(mana_replenished) + " mana.")
			for status in statusNegations.keys():
				if (player_data['statuses'][status] - statusNegations[status]) >= 0:
						player_data['statuses'][status] -= statusNegations[status]
						if statusNegations[status] > 0:
							chatBox.append_text("\nNegated " + str(status) + " by " + str(statusNegations[status]))
			# remove item when it's effects are done being applied
			player_data['quick_slots']['slot' + str(current_item_index+1)] = null
			get_node("HUDLayer/CanvasGroup/quickItemConsumeSound").play()
		# if it's the flashlight toggle it
		if item_id == "item012":
			get_node("HUDLayer/CanvasGroup/quickItemConsumeSound").play()
			if light.is_visible():
				light.hide()
			else:
				light.show()
		# if it's a spell
		# TODO: This needs to be more elaborate
		if item_id == "spell001":
			spell_active = true
			
		# update the quick slots now that items are used
		update_quick_slots()
	if event.is_action_released("item_consume"):
		if current_item_index == 3:
			spell_active = false
	if event.is_action_pressed("attack"):
		if not block_held:
			attack_held = true
		else:
			attack_held = false
	if event.is_action_released("attack"):
		attack_held = false
	if event.is_action_pressed("block"):
		if not attack_held:
			block_held = true
		else:
			block_held = false
	if event.is_action_released("block"):
		block_held = false
	if event.is_action_pressed("walk_up"):
		player_sprite.set_frame_coords(Vector2i(0, 3))
		walk_up_held = true
	if event.is_action_released("walk_up"):
		walk_up_held = false
	if event.is_action_pressed("walk_down"):
		player_sprite.set_frame_coords(Vector2i(0, 0))
		walk_down_held = true
	if event.is_action_released("walk_down"):
		walk_down_held = false
	if event.is_action_pressed("walk_left"):
		player_sprite.set_frame_coords(Vector2i(0, 1))
		walk_left_held = true
	if event.is_action_released("walk_left"):
		walk_left_held = false
	if event.is_action_pressed("walk_right"):
		player_sprite.set_frame_coords(Vector2i(0, 2))
		walk_right_held = true
	if event.is_action_released("walk_right"):
		walk_right_held = false
	if event.is_action_pressed("dash"):
		#chatBox.append_text("\n[i]Player has pressed dash.[/i]")
		dash = true
	if event.is_action_released("dash"):
		#chatBox.append_text("\n[i]Player has let go of dash.[/i]")
		dash = false
	if event.is_action_pressed("pause"):
		if playerMenu.visible:
			playerMenu.hide()
		elif get_tree().paused:
			print("unpausing")
			get_tree().paused = false
			pauseMenu.hide()
		else:
			print("pausing")
			get_tree().paused = true
			pauseMenu.show()
			pauseMenu.get_node('resumeGameButton').grab_focus()
	if event.is_action_pressed("playerMenu"):
		if playerMenu.visible:
			playerMenu.hide()
		else:
			playerMenu.show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_passed += delta
	var collision_data
	
	# flicker the player's light
	light.set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.1,.1), rng.randf_range(-.1,.1)))
	light.energy = 7.05 + rng.randf_range(-1,1)
	
	# adjust player's speed based on whether dash status is active
	# condition to dash
	if dash && player_data['current_stamina'] > 0 && (walk_down_held or walk_left_held or walk_right_held or walk_up_held):
		speed = base_speed * 2 
		if player_data['current_stamina'] - player_data['stamina_depl_rate'] * delta >= 0:
			player_data['current_stamina'] = player_data['current_stamina'] - player_data['stamina_depl_rate']*delta
		else:
			player_data['current_stamina'] = 0
	# cannot dash if no stamina
	elif dash && player_data['current_stamina'] == 0 && (walk_down_held or walk_left_held or walk_right_held or walk_up_held):
		speed = base_speed
	# only regen stamina if dash isn't held down when the current stamina is fully depleted.
	else:
		speed = base_speed
		# regen stamina
		if player_data['current_stamina'] + player_data['stamina_regen_rate'] * delta <= player_data['max_stamina']:
			player_data['current_stamina'] = player_data['current_stamina'] + player_data['stamina_regen_rate']*delta
		else:
			player_data['current_stamina'] = player_data['max_stamina']

	# redraw stamina bar
	stamina_bar.set_size(Vector2(player_data['current_stamina']/player_data['max_stamina'] * stamina_bar_length, stamina_bar_height))
	
	# set up attacks and blocks so you can only do one at a time
	if attack_held:
		pass
		#chatBox.append_text("\n[i]Player is attacking.[/i]")
	if block_held:
		# show block shield
		player_body.get_node("ColorRect").show()
		#chatBox.append_text("\n[i]Player is blocking.[/i]")
	else:
		# hide block shield
		player_body.get_node("ColorRect").hide()	

	# set up movement
	if walk_up_held:
		#currentMap.set_position(currentMap.get_position() + speed * Vector2(0, 0.25))
		#player_body.set_position(player_body.get_position() + speed *Vector2(0, -0.25))
		collision_data = player_body.move_and_collide(Vector2(0,-1) * speed)
		playerAnimationPlayer.play("walk_up")
	elif walk_down_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(0, -0.25))
		#player_body.set_position(player_body.get_position() + speed *Vector2(0, 0.25))
		collision_data = player_body.move_and_collide(Vector2(0,1)* speed)
		playerAnimationPlayer.play("walk_down")
	elif walk_left_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(0.25, 0))
		#player_body.set_position(player_body.get_position() + speed *Vector2(-0.25, 0))
		collision_data = player_body.move_and_collide(Vector2(-1,0)* speed)
		playerAnimationPlayer.play("walk_left")
	elif walk_right_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(-0.25, 0))			
		#player_body.set_position(player_body.get_position() + speed *Vector2(0.25, 0))
		collision_data = player_body.move_and_collide(Vector2(1,0) * speed)
		playerAnimationPlayer.play("walk_right")
	else:
		playerAnimationPlayer.stop()
		
	# check to see if collision occured
	if collision_data:
		chatBox.append_text("\n[i]Player has collided.[/i]")
		print(collision_data.get_collider())
	
	# Spell casting shit
	if spell_active && player_data['current_mana'] > 0: 
		# cast the spell in direction of mouse
		# TODO: adjust emission based on spell being cast
		emmisionNode.set_emitting(true)
		# aim with controller if possible
		#emmisionNode.get_process_material().set_direction(Vector3(Input.get_joy_axis(JOY_AXIS_RIGHT_X) - player_body.position.x, get_global_mouse_position().y - player_body.position.y, 0))
		emmisionNode.get_process_material().set_direction(Vector3(get_global_mouse_position().x - player_body.position.x, get_global_mouse_position().y - player_body.position.y, 0))
		if not player_body.get_node("spellSoundPlayer").is_playing():
			player_body.get_node("spellSoundPlayer").play()
		if player_data['current_mana'] - player_data['mana_depl_rate'] * delta >= 0:
			player_data['current_mana'] = player_data['current_mana'] - player_data['mana_depl_rate']*delta
		else:
			player_data['current_mana'] = 0
	# cannot cast if no mana
	elif spell_active && player_data['current_mana'] == 0:
		emmisionNode.set_emitting(false)
		player_body.get_node("spellSoundPlayer").stop()
	# only regen mana if spellcasting isn't held down when the current mana is fully depleted.
	else:
		emmisionNode.set_emitting(false)
		player_body.get_node("spellSoundPlayer").stop()
		# regen mana
		if player_data['current_mana'] + player_data['mana_regen_rate'] * delta <= player_data['max_mana']:
			player_data['current_mana'] = player_data['current_mana'] + player_data['mana_regen_rate']*delta
		else:
			player_data['current_mana'] = player_data['max_mana']

	# redraw mana bar
	mana_bar.set_size(Vector2(player_data['current_mana']/player_data['max_mana'] * mana_bar_length, mana_bar_height))
		
# Options menu buttons 
func _on_button_3_pressed():
	get_tree().paused = false
	get_tree().quit()
func _on_button_2_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
func _on_button_4_pressed():
	get_tree().paused = false
	pauseMenu.hide()
func _on_button_pressed():
	optionsMenu.get_node("Node2D/CanvasLayer").show()
	pauseMenu.hide()
