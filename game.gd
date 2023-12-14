extends Node2D

var rng

var currentZoom = 1

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

var health_target

# player data
var player_data

# lore data and stuff derived from it
var lore_data
var all_quick_items # contains all the quick items
var all_weapons
var all_armors
var all_items

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
var last_walk_up_held = false
var last_walk_down_held = false
var last_walk_left_held = false
var last_walk_right_held = false
var paralyzer = 1
var confused = false
var block_held = false
var attack_held = false
var block_held_t_interval = 0
var just_took_damage = false
var just_took_partial_damage = false
var damage_highlight_time = 0
var damage_partial_highlight_time = 0

var time_passed = 0.0
var playerAnimationPlayer
var boss1ScenePath = "res://boss1.tscn"
var dungeonScenePath = "res://dungeon.tscn"
var hoverSound

var item_slot_frame
var item_slot_frame_initial_position
var current_item_index = 0
var dash = false
var base_speed = 1 # will be adjusted dynamically in game by weight and load (also contains delta scaling factor)
var speed = base_speed # will be adjusted dynamically in game by dashse

var mouse_event_pos
var mouse_event_global_pos
var emmisionNode
var spell_active

var interaction # determines if the E key is being pressed

var backgroundMusic

# to programatically simulate an item_consume input event
var item_consume_event

# for camera shake effect
# The starting range of possible offsets using random values
var RANDOM_SHAKE_STRENGTH: float = 30.0
# Multiplier for lerping the shake strength to zero
var SHAKE_DECAY_RATE: float = 5.0
var shake_strength: float = 0.0

func apply_shake(shake_strength_given := RANDOM_SHAKE_STRENGTH) -> void:
	shake_strength = shake_strength_given

func get_random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)
	
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
	playerAnimationPlayer = get_node("player/PlayerAnimationPlayer")
	
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
	
	# get background music player from global 
	backgroundMusic = get_node("/root/Music")
	backgroundMusic.playing = false
	
	# Get player and lore data from global variables
	player_data = GlobalVars.player_data
	# TODO: make it seperate from lore.json
	#var file = FileAccess.open("lore/lore.json", FileAccess.READ)
	#player_data = JSON.new().parse_string(file.get_as_text())['character']
	#file.close()
	lore_data = GlobalVars.lore_data
	all_quick_items = lore_data['items'] + lore_data['spells'] + lore_data['questitems']
	all_weapons = lore_data['weapons']
	all_armors = lore_data['armors']
	
	# TODO: fully add armor support in json
	all_items = all_quick_items + all_weapons + all_armors
	
	# set up the artificial item_consume input event
	item_consume_event = InputEventAction.new()
	item_consume_event.action = "item_consume"
	item_consume_event.pressed = true
	
	# set up the patient's chat box
	chatBox = get_node('HUDLayer/CanvasGroup/chatBox')
	chatBox.append_text("[i]" + player_data.name +" has spawned.[/i]")
	
	# set up the chat box popup for interactions with npcs
	chatPopup = get_node("HUDLayer/chatPopup")
	chatPopup.hide()
	
	# get the item slot frame
	item_slot_frame = get_node("HUDLayer/CanvasGroup/slotFrame")
	item_slot_frame_initial_position = item_slot_frame.get_position()
	
	# load in the options menu
	var options_resource = ResourceLoader.load("res://options.tscn")
	var options_scene = options_resource.instantiate()
	optionsMenu = get_node("options")
	optionsMenu.add_child(options_scene)
	optionsMenu.get_node("Node2D/CanvasLayer").hide()
	
	# set up the lore tab 
	get_node("CanvasLayer2/playerMenu/Lore/VBoxContainer2/RichTextLabel").set_text(lore_data['promotional'])

	# OPTIONAL: Give player all the quick items
	#for item in all_quick_items:
	#	player_data['inventory'].append(item['id'])
	
	# OPTIONAL: Give player all the weapon items
	for item in all_weapons:
		player_data['inventory'].append(item['id'])
		
	# OPTIONAL: Give player all the armor items
	for item in all_armors:
		player_data['inventory'].append(item['id'])
	
	# set up this variable for smooth health bar transitions
	health_target = player_data['current_health']
	
	# set up the player inventory tab
	update_player_inventory()
	
	# set up the player equipment tab
	update_player_equipment()
	
	# set up the player stats tab
	update_player_stats_tab()
	
	# set up the player summary bar
	update_player_summary_bar()
	
	# set the textures for the items in the player's quickslots
	# make sure you update the quickslots everytime the player changes shit
	update_quick_slots()
	
	# load in actual game map
	#var scene_resource = ResourceLoader.load(boss1ScenePath)
	var scene_resource = ResourceLoader.load(dungeonScenePath)
	var scene = scene_resource.instantiate()
	currentMap = self.get_node("currentMap")
	currentMap.add_child(scene)
	backgroundMusic.stream = load(currentMap.get_node('Node2D').map_music)
	backgroundMusic.play()
	playTitleCard(currentMap.get_node('Node2D').map_name)
	

func playTitleCard(title: String):
	get_node("HUDLayer/titleCard/areaTitle").set_text(title)
	get_node("HUDLayer/titleCard/AnimationPlayer").play('fade_in')
	#get_node("HUDLayer/titleCard").hide()

# useful function for searching through a list of json documents 
# and retrieving the value for a key for a document that has a certain id
func searchDocsInList(list, uniquekey: String, uniqueid: String, key: String):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			if key in doc.keys():
				return doc[key]
			else:
				return null
	return null

# useful function for searching through a list of json documents
# and retrieving doc where there is a certain value for a certain key
func returnDocInList(list, uniquekey, uniqueid):
	for doc in list:
		if doc[uniquekey] == uniqueid:
			return doc
	return null
	
# useful function for making an array unique
func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique
	
func update_player_stats_tab():
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer2/vocationDesc").set_text(searchDocsInList(lore_data['vocations'],'class_name', player_data['vocation'], 'lore'))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer/Label2").set_text(str(player_data['stats']['attack']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer2/Label2").set_text(str(player_data['stats']['defense']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer3/Label2").set_text(str(player_data['stats']['strength']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer4/Label2").set_text(str(player_data['stats']['health']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer5/Label2").set_text(str(player_data['stats']['stamina']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer6/Label2").set_text(str(player_data['stats']['magic']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer7/Label2").set_text(str(player_data['stats']['wisdom']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer8/Label2").set_text(str(player_data['stats']['mana']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer9/Label2").set_text(str(player_data['current_level']))
	get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer/HBoxContainer10/Label2").set_text(str(player_data['current_exp']))

	var otherstats = get_node("CanvasLayer2/playerMenu/Stats/VBoxContainer2/HBoxContainer/otherStats")
	otherstats.clear()
	otherstats.append_text("\nWeight: " + str(player_data['weight']))
	otherstats.append_text("\nInventory Weight: " + str(player_data['inventory_weight'])) 
	otherstats.append_text("\nBase Speed: " + str(base_speed))
	otherstats.append_text('\n\n' + "[color=purple]Poisoned[/color]: " + str(snapped(player_data['statuses']['poisoned'], 0.01)))
	otherstats.append_text('\n' + "[color=orange]Burned[/color]: " + str(snapped(player_data['statuses']['burned'],0.01)))
	otherstats.append_text('\n' + "[color=blue]Drenched[/color]: " + str(snapped(player_data['statuses']['drenched'],0.01)))
	otherstats.append_text('\n' + "[color=green]Confused[/color]: " + str(snapped(player_data['statuses']['confused'],0.01)))
	otherstats.append_text('\n' + "[color=yellow]Paralyzed[/color]: " + str(snapped(player_data['statuses']['paralyzed'],0.01)))
	otherstats.append_text('\n' + "[color=red]Bloodless[/color]: " + str(snapped(player_data['statuses']['bloodless'],0.01)))
	
# updates the player summary bar text at the top of the screen
func update_player_summary_bar():
	var bar = get_node("HUDLayer/CanvasGroup/playersummarybarcontainer/playersummarybar")
	bar.clear()
	bar.append_text(player_data['name'] + ' | Level ' + str(player_data['current_level']) + ' | ' + player_data['vocation'])
	bar.append_text('\n')
	if player_data['statuses']["burned"] >= 1:
		bar.append_text("[img=20]res://assets/fire1.png[/img]")
	if player_data['statuses']["bloodless"] >= 1:
		bar.append_text("[img=20]res://assets/dark4.png[/img]")
	if player_data['statuses']["drenched"] >= 1:
		bar.append_text("[img=20]res://assets/water2.png[/img]")
	if player_data['statuses']["poisoned"] >= 1:
		bar.append_text("[img=20]res://assets/thunder5.png[/img]")
	if player_data['statuses']["confused"] >= 1:
		bar.append_text("[img=20]res://assets/earth2.png[/img]")
	if player_data['statuses']["paralyzed"] >= 1:
		bar.append_text("[img=20]res://assets/light3.png[/img]")
	get_node("HUDLayer/CanvasGroup/playersummarybarcontainer/TextureRect/gold").set_text(str(player_data['gold']))

# updates items in player quick slots
func update_quick_slots():
	for slot in player_data['quick_slots'].keys():
		var item_id = player_data['quick_slots'][slot]
		if item_id:
			var texturepath = searchDocsInList(all_quick_items, "id", item_id, 'sprite_data')
			var itemname = searchDocsInList(all_quick_items, "id", item_id, 'name')
			var itemdesc = searchDocsInList(all_quick_items, "id", item_id, 'description')
			var consumable = searchDocsInList(all_quick_items, "id", item_id, 'is_consumable')
			if texturepath:	
				#print(texturepath)
				# draw the item textures in the quickslots
				get_node("%" + slot).set_texture(load(texturepath))
				get_node("%" + slot).set_tooltip_text(itemname + '\n' + itemdesc)
				get_node("%" + slot + '/Label').set_text("")
				if consumable:
					var count = player_data['inventory'].count(item_id)
					if count > 1:
						get_node("%" + slot + '/Label').set_text(str(count))
		else:
			# there is not item in the slot
			# clean up the slot
			get_node("%" + slot).texture = null
			get_node("%" + slot).set_tooltip_text("")
			get_node("%" + slot + '/Label').set_text("")

# updates the player equipment tab
# TODO: make this better
func update_player_equipment():
	get_node('CanvasLayer2/playerMenu/Equipment/HBoxContainer/RichTextLabel').set_text("")
	get_node('CanvasLayer2/playerMenu/Equipment/HBoxContainer/RichTextLabel').set_text(JSON.stringify(player_data['equipment']))
	
	# adjust the status inflictions and negations
	# first set it all to zero
	for key in player_data['statusInflictions'].keys():
		player_data['statusInflictions'][key] = 0
		player_data['statusNegations'][key] = 0
	# then loop and add
	for key in player_data['equipment'].keys():
		var item = {}
		item = returnDocInList(all_items, 'id', player_data['equipment'][key])
		if item:
			if 'statusInflictions' in item.keys():
				for key2 in item['statusInflictions']:
					player_data['statusInflictions'][key2] += item['statusInflictions'][key2]
			if 'statusNegations' in item.keys():
				for key2 in item['statusNegations']:
					player_data['statusNegations'][key2] += item['statusNegations'][key2]
	
	var inflictions = get_node('CanvasLayer2/playerMenu/Equipment/HBoxContainer/statusInflictions')
	inflictions.clear()
	inflictions.append_text('\nStatus Offensives')	
	inflictions.append_text('\n\n' + "[color=purple]Poisoned[/color]: " + str(snapped(player_data['statusInflictions']['poisoned'], 0.01)))
	inflictions.append_text('\n' + "[color=orange]Burned[/color]: " + str(snapped(player_data['statusInflictions']['burned'],0.01)))
	inflictions.append_text('\n' + "[color=blue]Drenched[/color]: " + str(snapped(player_data['statusInflictions']['drenched'],0.01)))
	inflictions.append_text('\n' + "[color=green]Confused[/color]: " + str(snapped(player_data['statusInflictions']['confused'],0.01)))
	inflictions.append_text('\n' + "[color=yellow]Paralyzed[/color]: " + str(snapped(player_data['statusInflictions']['paralyzed'],0.01)))
	inflictions.append_text('\n' + "[color=red]Bloodless[/color]: " + str(snapped(player_data['statusInflictions']['bloodless'],0.01)))
	var negations = get_node('CanvasLayer2/playerMenu/Equipment/HBoxContainer/statusNegations')
	negations.clear()
	negations.append_text('\nStatus Resistances')	
	negations.append_text('\n\n' + "[color=purple]Poisoned[/color]: " + str(snapped(player_data['statusNegations']['poisoned'], 0.01)))
	negations.append_text('\n' + "[color=orange]Burned[/color]: " + str(snapped(player_data['statusNegations']['burned'],0.01)))
	negations.append_text('\n' + "[color=blue]Drenched[/color]: " + str(snapped(player_data['statusNegations']['drenched'],0.01)))
	negations.append_text('\n' + "[color=green]Confused[/color]: " + str(snapped(player_data['statusNegations']['confused'],0.01)))
	negations.append_text('\n' + "[color=yellow]Paralyzed[/color]: " + str(snapped(player_data['statusNegations']['paralyzed'],0.01)))
	negations.append_text('\n' + "[color=red]Bloodless[/color]: " + str(snapped(player_data['statusNegations']['bloodless'],0.01)))

# updates the player inventory
func update_player_inventory():
	# set up the player inventory
	var inventoryList = get_node("CanvasLayer2/playerMenu/Inventory/HBoxContainer/ScrollContainer/inventoryList")
	# clear children of inventory list
	for n in inventoryList.get_children():
		inventoryList.remove_child(n)
		n.queue_free()
	
	# now redraw the children	
	var buttongroup = ButtonGroup.new()
	var buttonLoreShow = func(item):
		var desc = get_node("CanvasLayer2/playerMenu/Inventory/HBoxContainer/selectedInventoryItemDesc")
		desc.set_text('[center][font_size=12]\n' + item['name'] + "[/font_size]\n[img=50]" + item['sprite_data'] + "[/img][/center]" + '\n' + JSON.stringify(item))
	
	# load in all the items from the player inventory json data
	var current_inventory_items = []
	for item_id in player_data['inventory']:
		current_inventory_items.append(returnDocInList(all_items, 'id', item_id))
	
	# get player total item weight
	var inventory_weight = 0
	for item in current_inventory_items:
		if "weight" in item.keys():
			inventory_weight += item['weight']
		else:
			# assume that the weight of an item is one
			inventory_weight += 1
	player_data['inventory_weight'] = inventory_weight
	#print(inventory_weight)
	# adjust player speed here, based on the weight being carried
	var apparent_inventory_weight = inventory_weight - player_data['stats']['strength']
	if apparent_inventory_weight < 0:
		apparent_inventory_weight = 0
	base_speed = 1 - (apparent_inventory_weight/player_data['weight'])*0.75
	if base_speed <= 0:
		base_speed = 0
	base_speed *= 50 # number of pixels a second
	update_player_stats_tab() # to reflect new weight and stuff
	
	for item in array_unique(current_inventory_items):
		var itemButton = MenuButton.new()		
		itemButton.flat = false
		itemButton.get_popup().add_theme_font_size_override("font_size", 9)
		itemButton.get_popup().set_max_size(Vector2(100,900))
		itemButton.add_theme_font_size_override("font_size",9)
		
		# for items that are quick slottable:
		if item['id'].contains("spell") || item['id'].contains("item") || item['id'].contains("questitem"):
			var slotMenu = PopupMenu.new()
			slotMenu.set_name('slotMenu')
			slotMenu.add_theme_font_size_override("font_size", 9)
			slotMenu.set_max_size(Vector2(100,900))
			slotMenu.add_check_item("Slot 1")
			slotMenu.add_check_item("Slot 2")
			slotMenu.add_check_item("Slot 3")
			slotMenu.add_check_item("Slot 4")
			slotMenu.add_check_item("Slot 5")
			slotMenu.add_check_item("Slot 6")
			itemButton.get_popup().add_child(slotMenu)		
			itemButton.get_popup().add_submenu_item("Quickslot", "slotMenu")
			itemButton.get_popup().add_separator()
			slotMenu.index_pressed.connect(addItemToSlot.bind(item))
			
		# for items that are equippable
		if "is_equipable" in item.keys():
			if item['is_equipable']:
				var equipMenu = PopupMenu.new()
				equipMenu.set_name('equipMenu')
				equipMenu.add_theme_font_size_override("font_size", 9)
				equipMenu.set_max_size(Vector2(100,900))
				
				# TODO: only show options based on item type
				if 'head' in item['slots']:
					equipMenu.add_check_item("head", 1)
				if 'back' in item['slots']:
					equipMenu.add_check_item("back", 2)
				if 'torso' in item['slots']:
					equipMenu.add_check_item("torso", 3)
				if 'leftarm' in item['slots']:
					equipMenu.add_check_item("leftarm", 4)
				if 'rightarm' in item['slots']:
					equipMenu.add_check_item("rightarm", 5)
				if 'legs' in item['slots']:
					equipMenu.add_check_item("legs", 6)
				if 'feet' in item['slots']:
					equipMenu.add_check_item("feet", 7)
				if 'talisman1' in item['slots']:
					equipMenu.add_check_item("talisman1", 8)
				if 'talisman2' in item['slots']:
					equipMenu.add_check_item("talisman2", 9)
				if 'talisman3' in item['slots']:
					equipMenu.add_check_item("talisman3", 10)
				if 'talisman4' in item['slots']:
					equipMenu.add_check_item("talisman4", 11)
				if 'neck' in item['slots']:
					equipMenu.add_check_item("neck", 12)
				itemButton.get_popup().add_child(equipMenu)
				itemButton.get_popup().add_submenu_item("Equip", "equipMenu")
				itemButton.get_popup().add_separator()
				equipMenu.id_pressed.connect(addItemToEquip.bind(item))
		
		# for items that are consumable
		if "is_consumable" in item.keys():
			if item['is_consumable']:
				itemButton.get_popup().add_item("Consume", 1)
			
		# for items that are stackable
		var itemButtonText = item['name']
		if "is_stackable" in item.keys():
			if item['is_stackable']:
				itemButtonText += ' (' + str(player_data['inventory'].count(item['id'])) + ')'
		
		# if the item in already in a quick slot
		if item['id'] in player_data['quick_slots'].values():
			itemButtonText += "\nin quick slot"
			
		# if the item is in an equipment slot
		if item['id'] in player_data['equipment'].values():
			itemButtonText += "\nequipped"
			itemButton.get_popup().add_item("Unequip", 4)
			
		# all items will be discardable
		itemButton.get_popup().add_item("Discard", 3)
		
		itemButton.set_text(itemButtonText)
		itemButton.set_button_icon(load(item['sprite_data']))
		itemButton.set_toggle_mode(true)
		itemButton.set_button_group(buttongroup)
		inventoryList.add_child(itemButton)
		itemButton.pressed.connect(buttonLoreShow.bind(item))
		itemButton.get_popup().id_pressed.connect(inventoryItemPopupMenuPress.bind(item))

func removeItemFromEquip(item):
	# remove item if it's in an equipment slot
	for key in player_data['equipment'].keys():
		if player_data['equipment'][key] == item['id']:
			player_data['equipment'][key] = null
	update_player_equipment()

func addItemToEquip(equip_index, item):
	# if the item is already equipped, remove it
	removeItemFromEquip(item)
		
	# now add the item overwriting another item that may be there
	if equip_index == 1:
		player_data['equipment']['head'] = item['id']
	if equip_index == 2:
		player_data['equipment']['back'] = item['id']
	if equip_index == 3:
		player_data['equipment']['torso'] = item['id']
	if equip_index == 4:
		player_data['equipment']['leftarm'] = item['id']
	if equip_index == 5:
		player_data['equipment']['rightarm'] = item['id']
	if equip_index == 6:
		player_data['equipment']['legs'] = item['id']	
	if equip_index == 7:
		player_data['equipment']['feet'] = item['id']
	if equip_index == 8:
		player_data['equipment']['talisman1'] = item['id']
	if equip_index == 9:
		player_data['equipment']['talisman2'] = item['id']
	if equip_index == 10:
		player_data['equipment']['talisman3'] = item['id']
	if equip_index == 11:
		player_data['equipment']['talisman4'] = item['id']
	if equip_index == 12:
		player_data['equipment']['neck'] = item['id']
	
	get_node('CanvasLayer2/playerMenu/equipSound').play()
	
	update_player_inventory()
	update_player_equipment()
			
func addItemToSlot(slot_index, item):
	# try to remove item from quickslots if it's already in there
	removeItemFromQuickslot(item)

	# get the item in the intended quickslot
	var oldItemId = player_data['quick_slots']['slot'+str(slot_index+1)]
	# if item is a flashlight turn it off as it is not in the quickslots anymore
	if oldItemId == "item012":
		light.hide()
	# add item to quickslot, possibly overwriting another item that was there 
	player_data['quick_slots']['slot'+str(slot_index+1)] = item['id']
	
	get_node('HUDLayer/CanvasGroup/quickItemSwitchSound').play()
	update_quick_slots()
	update_player_inventory()
	
func removeItemFromInventory(item):
	# remove item from player_data['inventory']
	var i = player_data['inventory'].find(item['id'])

	if i != -1:
		player_data['inventory'].remove_at(i)
		# if item is a flashlight turn it off as it is discarded from inventory
		if item['id'] == "item012":
			light.hide()
		
	# if there's not another item of its kind left in inventory, remove from quickslot
	if player_data['inventory'].find(item['id']) == -1:
		removeItemFromQuickslot(item)
	
func removeItemFromQuickslot(item):
	for key in player_data['quick_slots'].keys():
		if item['id'] == player_data['quick_slots'][key]:
			player_data['quick_slots'][key] = null
			get_node('HUDLayer/CanvasGroup/quickItemSwitchSound').play()
		
func inventoryItemPopupMenuPress(id, item):
	if id == 1: # for consuming items
		consumeItem(item)
		get_node("HUDLayer/CanvasGroup/quickItemConsumeSound").play()
	if id == 3: # for discarding items
		removeItemFromInventory(item)
		get_node('CanvasLayer2/playerMenu/discardSound').play()
	if id == 4: # for unequipping items
		removeItemFromEquip(item)
		get_node('CanvasLayer2/playerMenu/unequipSound').play()
		
	update_player_inventory()
	update_quick_slots()
	# clear any current item description showing
	get_node("CanvasLayer2/playerMenu/Inventory/HBoxContainer/selectedInventoryItemDesc").set_text("")
	
func consumeItem(item):
	var item_id = item['id']
	# check to see if item is consumable
	var consumable
	if 'is_consumable' in item.keys():
		consumable = item["is_consumable"]
	if consumable:
		# consume whatever current item is active
		var health_replenished = searchDocsInList(all_quick_items, 'id', item_id, "health_replenished")
		var mana_replenished = searchDocsInList(all_quick_items, 'id', item_id, "mana_replenished")
		var stamina_replenished = searchDocsInList(all_quick_items, 'id', item_id, "stamina_replenished") 
		var statusNegations = {}
		statusNegations = searchDocsInList(all_quick_items, 'id', item_id, "statusNegations") 
		if player_data['current_health'] + health_replenished <= player_data['max_health']:
			player_data['current_health'] += health_replenished
		else:
			player_data['current_health'] = player_data['max_health']
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
	
		# after consumed remove item from inventory
		removeItemFromInventory(item)
	
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
		mouse_event_global_pos = get_global_mouse_position()
		# move the player's melee collision shape
		get_node('player/hitBox').look_at(mouse_event_global_pos)
	if event.is_action_pressed("zoom_in") and not playerMenu.visible:
		if currentZoom <= 2:
			currentZoom += 0.03
		else:
			currentZoom = 2
		player_body.get_node("sprite/Camera2D").set_zoom(Vector2(currentZoom, currentZoom))
	if event.is_action_pressed("zoom_out") and not playerMenu.visible:
		if currentZoom >= 0.5:
			currentZoom -= 0.03
		else:
			currentZoom = 0.5
		player_body.get_node("sprite/Camera2D").set_zoom(Vector2(currentZoom, currentZoom))
	if event.is_action_pressed("item_1"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 0 and player_data["quick_slots"]['slot' + str(current_item_index+1)]:
			if not player_data["quick_slots"]['slot' + str(current_item_index+1)].contains("spell"):
				Input.parse_input_event(item_consume_event)
		else:
			current_item_index = 0
			item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_2"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 1 and player_data["quick_slots"]['slot' + str(current_item_index+1)]:
			if not player_data["quick_slots"]['slot' + str(current_item_index+1)].contains("spell"):
				Input.parse_input_event(item_consume_event)
		else:
			current_item_index = 1
			item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_3"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 2 and player_data["quick_slots"]['slot' + str(current_item_index+1)]:
			if not player_data["quick_slots"]['slot' + str(current_item_index+1)].contains("spell"):
				Input.parse_input_event(item_consume_event)
		else:
			current_item_index = 2
			item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_4"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 3 and player_data["quick_slots"]['slot' + str(current_item_index+1)]:
			if not player_data["quick_slots"]['slot' + str(current_item_index+1)].contains("spell"):
				Input.parse_input_event(item_consume_event)
		else:
			current_item_index = 3
			item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_5"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 4 and player_data["quick_slots"]['slot' + str(current_item_index+1)]:
			if not player_data["quick_slots"]['slot' + str(current_item_index+1)].contains("spell"):
				Input.parse_input_event(item_consume_event)
		else:
			current_item_index = 4
			item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_6"):
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 5 and player_data["quick_slots"]['slot' + str(current_item_index+1)]:
			if not player_data["quick_slots"]['slot' + str(current_item_index+1)].contains("spell"):
				Input.parse_input_event(item_consume_event)
		else:
			current_item_index = 5
			item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))				
	if event.is_action_pressed("item_left"):
		# cancel any currently running spells
		spell_active = false
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 0:
			current_item_index = 5
		else:
			current_item_index -= 1
		item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_right"):
		# cancel any currently running spells
		spell_active = false
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if current_item_index == 5:
			current_item_index = 0
		else:
			current_item_index += 1
		item_slot_frame.set_position(item_slot_frame_initial_position + current_item_index * Vector2(46,0))
	if event.is_action_pressed("item_consume") and not confused and not player_data['is_dead']:
		var item_id = player_data['quick_slots']['slot' + str(current_item_index+1)]
		# make sure there's actually an item in the slot
		if item_id:
			var item = {}
			# grab the item doc
			item = returnDocInList(all_quick_items, 'id', item_id)
			if 'is_consumable' in item.keys():
				if item['is_consumable']:
					consumeItem(item)
					get_node("HUDLayer/CanvasGroup/quickItemConsumeSound").play()
					# remove item when it's effects are done being applied and there's none left in inventory
					if player_data['inventory'].find(item['id']) == -1:
						player_data['quick_slots']['slot' + str(current_item_index+1)] = null
					
			# CODE FOR SPECIAL ITEMS LIKE SPELLS AND TOGGLE ITEMS
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
			
			# redraw the quick slots
			update_quick_slots()
			# redraw the inventory if it was open during consumptions
			if playerMenu.visible:
				update_player_inventory()
			
	if event.is_action_released("item_consume") and not confused and not player_data['is_dead']:
		# this is for stopping casting a spell
		var item_id = player_data["quick_slots"]['slot' + str(current_item_index+1)]
		if item_id:
			if item_id.contains("spell"):
				spell_active = false
	if event.is_action_pressed("attack") && !playerMenu.visible && !chatPopup.visible and not player_data['is_dead']:
		if not block_held:
			attack_held = true
			for body in get_node('player/hitBox').get_overlapping_bodies():
				if body.is_attackable:
					if body.has_method("take_damage") :
						body.take_damage(20, player_data['statusInflictions'])
			get_node('player/attackSoundPlayer').play()
			get_node("player/hitBox/Line2D").set_default_color(Color(1,0,0,1))
		else:
			attack_held = false
	if event.is_action_released("attack") and not player_data['is_dead']:
		get_node("player/hitBox/Line2D").set_default_color(Color(1,1,1,1))
		attack_held = false
	if event.is_action_pressed("block") and not player_data['is_dead']:
		if not attack_held:
			block_held = true
			block_held_t_interval = 0
			get_node("player/shieldSoundPlayer").play()
		else:
			block_held = false
	if event.is_action_released("block") and not player_data['is_dead']:
		block_held = false
	if event.is_action_pressed("walk_up") and not player_data['is_dead']:
		player_sprite.set_frame_coords(Vector2i(0, 3))
		walk_up_held = true
	if event.is_action_released("walk_up") and not player_data['is_dead']:
		walk_up_held = false
	if event.is_action_pressed("walk_down") and not player_data['is_dead']:
		player_sprite.set_frame_coords(Vector2i(0, 0))
		walk_down_held = true
	if event.is_action_released("walk_down") and not player_data['is_dead']:
		walk_down_held = false
	if event.is_action_pressed("walk_left") and not player_data['is_dead']:
		player_sprite.set_frame_coords(Vector2i(0, 1))
		walk_left_held = true
	if event.is_action_released("walk_left") and not player_data['is_dead']:
		walk_left_held = false
	if event.is_action_pressed("walk_right") and not player_data['is_dead']:
		player_sprite.set_frame_coords(Vector2i(0, 2))
		walk_right_held = true
	if event.is_action_released("walk_right") and not player_data['is_dead']:
		walk_right_held = false
	if event.is_action_pressed("dash") and not player_data['is_dead']:
		#chatBox.append_text("\n[i]Player has pressed dash.[/i]")
		dash = true
	if event.is_action_released("dash") and not player_data['is_dead']:
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
		get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
		if playerMenu.visible:
			playerMenu.hide()
		else:
			update_player_inventory()
			playerMenu.show()
	
	# item interaction in the world also uses the chat key
	if event.is_action_pressed("chat"):
		interaction = true
		for body in get_node('player/hitBox').get_overlapping_bodies():
			if body.is_ground_item:
				player_body.get_node('grabSoundPlayer').play()
				var itemname = searchDocsInList(all_items, 'id', body.item_id, 'name')
				if itemname:
					chatBoxAppend("Picked up " + itemname)
				else:
					chatBoxAppend("Picked up item with id " + body.item_id + ' could not find in database')
				# add item to the inventory	
				player_data['inventory'].append(body.item_id)
				# remove item from world.
				body.queue_free()
	if event.is_action_released("chat"):
		interaction = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_passed += delta
	
	var collision_data
	
	# screen shake effect if needed
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	player_body.get_node('sprite/Camera2D').offset = get_random_offset()
	
	# flicker the player's light
	light.set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.05,.05), rng.randf_range(-.05,.05)))
	light.energy = 1.5 + rng.randf_range(-.1,.1)
	
	# paralyze status effect
	if player_data['statuses']["paralyzed"] >= 1:
		player_body.get_node("LightningColorRect").show()
		# this is a variable that when multiplied by the speed, kills it
		paralyzer = 0
	else:
		player_body.get_node("LightningColorRect").hide()
		paralyzer = 1
		
	# adjust player's speed based on whether dash status is active
	# condition to dash
	if dash && player_data['current_stamina'] > 0 && (walk_down_held or walk_left_held or walk_right_held or walk_up_held):
		speed = base_speed * 2 * paralyzer
		if player_data['current_stamina'] - player_data['stamina_depl_rate'] * delta >= 0:
			player_data['current_stamina'] = player_data['current_stamina'] - player_data['stamina_depl_rate']*delta
		else:
			player_data['current_stamina'] = 0
	# cannot dash if no stamina
	elif dash && player_data['current_stamina'] == 0 && (walk_down_held or walk_left_held or walk_right_held or walk_up_held):
		speed = base_speed * paralyzer
	# only regen stamina if dash isn't held down when the current stamina is fully depleted.
	else:
		speed = base_speed * paralyzer
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
		player_body.get_node("ShieldColorRect").show()
		#chatBox.append_text("\n[i]Player is blocking.[/i]")
		# start incrementing the time it's being held
		block_held_t_interval += delta
	else:
		# hide block shield
		player_body.get_node("ShieldColorRect").hide()	

	# set up movement
	if walk_up_held:
		if walk_right_held:
			collision_data = player_body.move_and_collide(Vector2(1,-1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_up")
		elif walk_left_held:
			collision_data = player_body.move_and_collide(Vector2(-1,-1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_up")
		else:
			#currentMap.set_position(currentMap.get_position() + speed * Vector2(0, 0.25))
			#player_body.set_position(player_body.get_position() + speed *Vector2(0, -0.25))
			collision_data = player_body.move_and_collide(Vector2(0,-1) * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_up")
		last_walk_up_held = true
		last_walk_down_held = false
		last_walk_left_held = false
		last_walk_right_held = false
	elif walk_down_held:
		if walk_right_held:
			collision_data = player_body.move_and_collide(Vector2(1,1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_down")
		elif walk_left_held:
			collision_data = player_body.move_and_collide(Vector2(-1,1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_down")
		else:
			#currentMap.set_position(currentMap.get_position() + speed *Vector2(0, -0.25))
			#player_body.set_position(player_body.get_position() + speed *Vector2(0, 0.25))
			collision_data = player_body.move_and_collide(Vector2(0,1)* speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_down")
		last_walk_up_held = false
		last_walk_down_held = true
		last_walk_left_held = false
		last_walk_right_held = false
	elif walk_left_held:
		if walk_up_held:
			collision_data = player_body.move_and_collide(Vector2(-1,-1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_left")
		elif walk_down_held:
			collision_data = player_body.move_and_collide(Vector2(-1,1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_left")
		else:
			#currentMap.set_position(currentMap.get_position() + speed *Vector2(0.25, 0))
			#player_body.set_position(player_body.get_position() + speed *Vector2(-0.25, 0))
			collision_data = player_body.move_and_collide(Vector2(-1,0)* speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_left")
		last_walk_up_held = false
		last_walk_down_held = false
		last_walk_left_held = true
		last_walk_right_held = false
	elif walk_right_held:
		if walk_up_held:
			collision_data = player_body.move_and_collide(Vector2(1,-1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_right")
		elif walk_down_held:
			collision_data = player_body.move_and_collide(Vector2(1,1).normalized() * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_right")
		else:
			#currentMap.set_position(currentMap.get_position() + speed *Vector2(-0.25, 0))			
			#player_body.set_position(player_body.get_position() + speed *Vector2(0.25, 0))
			collision_data = player_body.move_and_collide(Vector2(1,0) * speed * paralyzer * delta)
			playerAnimationPlayer.play("walk_right")
		last_walk_up_held = false
		last_walk_down_held = false
		last_walk_left_held = false
		last_walk_right_held = true
	else:
		playerAnimationPlayer.stop() # or play idle animation

	# other status effect applications
	# by default turn their effects off 
		# make the player transiently red if attacked
	if just_took_damage:
		damage_highlight_time += delta
		player_sprite.modulate = Color(1,0.18,0.18,1)
		if damage_highlight_time > 0.3:
			damage_highlight_time = 0
			just_took_damage = false
	elif just_took_partial_damage:
		damage_partial_highlight_time += delta
		player_sprite.modulate = Color(0.50,0.18,0.18,1)
		if damage_partial_highlight_time > 0.3:
			damage_partial_highlight_time = 0
			just_took_partial_damage = false
	else:
		player_sprite.modulate = Color(1,1,1,1)
	player_body.get_node("trail").set_emitting(false)
	player_body.get_node("FireColorRect").hide()
	if player_data['statuses']["confused"] >= 1:
		confused = true
		player_body.get_node("confusionOverlay").show()
	else:
		confused = false
		player_body.get_node("confusionOverlay").hide()
	if player_data['statuses']["drenched"] >= 1 and not just_took_damage and not just_took_partial_damage:
		player_sprite.modulate = Color(0.37,0.62,0.63,1)
		if last_walk_up_held:
			collision_data = player_body.move_and_collide((Vector2(rng.randf_range(-1,1), -1).normalized()) * 2 * base_speed * delta)
		if last_walk_down_held:
			collision_data = player_body.move_and_collide((Vector2(rng.randf_range(-1,1), 1).normalized()) * 2 * base_speed * delta)
		if last_walk_left_held:
			collision_data = player_body.move_and_collide((Vector2(-1, rng.randf_range(-1,1)).normalized()) * 2 * base_speed * delta)
		if last_walk_right_held:
			collision_data = player_body.move_and_collide((Vector2(1, rng.randf_range(-1,1)).normalized()) * 2 * base_speed * delta)
		player_body.get_node("trail").get_process_material().set_color(Color(0.37,0.62,0.63,1))
		player_body.get_node("trail").set_emitting(true)
	if player_data['statuses']["poisoned"] >= 1 and not just_took_damage and not just_took_partial_damage:
		# make purple hue on sprite
		player_sprite.modulate = Color(1,0,1)
	if player_data['statuses']["burned"] >= 1:
		player_data['current_health'] -= 1 * delta
		player_body.get_node("FireColorRect").show()	
	if player_data['statuses']["bloodless"] >= 1:
		if walk_down_held or walk_up_held or walk_left_held or walk_right_held:
			if dash:
				player_data['current_health'] -= 3 * delta
			else:
				player_data['current_health'] -= 2 * delta
		player_body.get_node("trail").get_process_material().set_color (Color(1,0,0,1))
		player_body.get_node("trail").set_emitting(true)
	
	# check to see if collision occured
	if collision_data:
		#chatBox.append_text("\n[i]Player has collided.[/i]")
		var collider = collision_data.get_collider()
		# if it's a rigid body (aka a ground item, move it)
		if collider is RigidBody2D:
			#collision_data.get_collider().apply_central_impulse(-1 * collision_data.get_normal())
			pass
			
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
	
	# redraw health bar in a smooth fashion using health target
	var health_diff = health_target - player_data['current_health']
	if health_diff > 0:
		health_target -= 1
	if health_diff < 0:
		health_target += 1
	health_bar.set_size(Vector2(health_target/player_data['max_health'] * health_bar_length, health_bar_height))
	
	# natural status effect mitigation
	# TODO: can adjust based on class
	player_data['statuses']["poisoned"] -= 0.02 *delta
	player_data['statuses']["burned"] -= 0.02 *delta
	player_data['statuses']["drenched"] -= 0.02 *delta
	player_data['statuses']["confused"] -= 0.02 *delta
	player_data['statuses']["paralyzed"] -= 0.1 *delta
	player_data['statuses']["bloodless"] -= 0.02 *delta
	for key in player_data['statuses'].keys():
		if player_data['statuses'][key] < 0:
			player_data['statuses'][key] = 0
	update_player_stats_tab()
	update_player_summary_bar()
	
# for removing health
func subtractHealth(amount):
	if not player_data['is_dead']: # only subtract health if player isn't dead.
		player_data['current_health'] -= amount
		if player_data['current_health'] <= 0:
			player_data['current_health'] = 0
			player_data['is_dead'] = true
			chatBoxAppend(player_data['name'] + " died.")
			# turn off all current movement
			walk_up_held = false
			walk_left_held = false
			walk_right_held = false
			walk_down_held = false
			backgroundMusic.playing = false
			backgroundMusic.stream = load('res://assets/music/mindseyepack/2- Mental Vortex.mp3')
			backgroundMusic.play()
			# TODO: show the dead sprite
			light.hide()
			playTitleCard('YOU DIED.')
			
			# TODO: pull up the death menu
			

# for when you want to output to the chatbox
func chatBoxAppend(message):
	chatBox.append_text("\n" + message)
	
# for when you walk over coin
func hit_coin():
	# play coin collision sound
	get_node('%coinCollisionSound').play()
	player_data['gold'] += 1
	update_player_summary_bar()
		
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


func _on_player_menu_tab_changed(_tab):
	get_node("HUDLayer/CanvasGroup/quickItemSwitchSound").play()
