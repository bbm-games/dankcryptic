extends Node2D


var player_sprite
var currentMap

var walk_up_held = false
var walk_down_held = false
var walk_left_held = false
var walk_right_held = false
var time_passed = 0.0
var rng
var playerAnimationPlayer
var boss1ScenePath = "res://boss1.tscn"
var centralLight

var dash = false
var speed = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	player_sprite = get_node("player") 
	#map_sprite = get_node("Testbg")
	playerAnimationPlayer = get_node("PlayerAnimationPlayer")

	# load in boss battle scene
	var scene_resource = ResourceLoader.load(boss1ScenePath)
	var scene = scene_resource.instantiate()
	currentMap = self.get_node("currentMap")
	currentMap.add_child(scene)
	
	# get the central light from the map, it should follow the player
	centralLight = scene.get_node("PointLight2D")
	
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
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_passed += delta
	if dash:
		speed = 6
	else:
		speed = 3
	if walk_up_held:
		#currentMap.set_position(currentMap.get_position() + speed * Vector2(0, 0.25))
		centralLight.set_position(centralLight.get_position() + speed *Vector2(0, -0.25))
		player_sprite.set_position(player_sprite.get_position() + speed *Vector2(0, -0.25))
		playerAnimationPlayer.play("walk_up")
	elif walk_down_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(0, -0.25))
		centralLight.set_position(centralLight.get_position() + speed *Vector2(0, 0.25))
		player_sprite.set_position(player_sprite.get_position() + speed *Vector2(0, 0.25))
		playerAnimationPlayer.play("walk_down")
	elif walk_left_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(0.25, 0))
		centralLight.set_position(centralLight.get_position() + speed *Vector2(-0.25, 0))
		player_sprite.set_position(player_sprite.get_position() + speed *Vector2(-0.25, 0))
		playerAnimationPlayer.play("walk_left")
	elif walk_right_held:
		#currentMap.set_position(currentMap.get_position() + speed *Vector2(-0.25, 0))			
		centralLight.set_position(centralLight.get_position() + speed *Vector2(0.25, 0))
		player_sprite.set_position(player_sprite.get_position() + speed *Vector2(0.25, 0))
		playerAnimationPlayer.play("walk_right")
	else:
		playerAnimationPlayer.stop()
	
	
