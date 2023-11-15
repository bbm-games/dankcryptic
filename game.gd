extends Node2D

var rng

var player_body
var player_sprite
var light 

var currentMap
var pauseMenu
var playerMenu
var optionsMenu

var walk_up_held = false
var walk_down_held = false
var walk_left_held = false
var walk_right_held = false
var time_passed = 0.0
var playerAnimationPlayer
var boss1ScenePath = "res://boss1.tscn"
var dungeonScenePath = "res://dungeon.tscn"
var hoverSound

var dash = false
var speed = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	
	rng = RandomNumberGenerator.new()
	
	hoverSound = get_node("hoverSound")
	connect_buttons(get_tree().root)
	get_tree().node_added.connect(_on_SceneTree_node_added)
	
	pauseMenu = get_node("CanvasLayer/pauseMenu")
	pauseMenu.hide()
	
	playerMenu = get_node("CanvasLayer2/playerMenu")
	playerMenu.hide()
	
	player_body = get_node("player")
	player_sprite = get_node("player/sprite") 
	light = get_node("player/PointLight2D") 
	#map_sprite = get_node("Testbg")
	playerAnimationPlayer = get_node("PlayerAnimationPlayer")

	# load in the options menu
	var options_resource = ResourceLoader.load("res://options.tscn")
	var options_scene = options_resource.instantiate()
	optionsMenu = get_node("options")
	optionsMenu.add_child(options_scene)
	optionsMenu.get_node("Node2D/CanvasLayer").hide()
	
	# load in boss battle scene
	var scene_resource = ResourceLoader.load(boss1ScenePath)
	var scene = scene_resource.instantiate()
	currentMap = self.get_node("currentMap")
	currentMap.add_child(scene)

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
		dash = true
	if event.is_action_released("dash"):
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
	# flicker the player's light
	light.set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.1,.1), rng.randf_range(-.1,.1)))
	light.energy = 7.05 + rng.randf_range(-1,1)
	
	time_passed += delta
	if dash:
		speed = 1.5
	else:
		speed = 0.75
	if walk_up_held:
		#currentMap.set_position(currentMap.get_position() + speed * Vector2(0, 0.25))
		#player_body.set_position(player_body.get_position() + speed *Vector2(0, -0.25))
		player_body.move_and_collide(Vector2(0,-1) * speed)
		playerAnimationPlayer.play("walk_up")
	elif walk_down_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(0, -0.25))
		#player_body.set_position(player_body.get_position() + speed *Vector2(0, 0.25))
		player_body.move_and_collide(Vector2(0,1)* speed)
		playerAnimationPlayer.play("walk_down")
	elif walk_left_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(0.25, 0))
		#player_body.set_position(player_body.get_position() + speed *Vector2(-0.25, 0))
		player_body.move_and_collide(Vector2(-1,0)* speed)
		playerAnimationPlayer.play("walk_left")
	elif walk_right_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(-0.25, 0))			
		#player_body.set_position(player_body.get_position() + speed *Vector2(0.25, 0))
		player_body.move_and_collide(Vector2(1,0) * speed)
		playerAnimationPlayer.play("walk_right")
	else:
		playerAnimationPlayer.stop()

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
	
