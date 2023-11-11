extends Node2D
var bossSprite
var light
var rng
var bossInitiated = false
var playerSprite
var tileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	light = get_node("PointLight2D")
	tileMap = get_node('TileMap')
	
	bossSprite = get_node("boss")
	# start the boss up on idle animation
	bossSprite.play('idle')
	
	# if the scene is recruited by the main game scene
	# then instantiate the boss, otherwise just run the scene
	if(get_parent().get_parent()):
		initiateBoss(get_parent().get_parent().get_node('player'))
	else:
		pass
func turn_right():
	# change animation to attack animation
	bossSprite.set_flip_h(false)
	
func turn_left():
	# change animation to attack animation
	bossSprite.set_flip_h(true)
	
# intiate the boss by setting a boolean to true. Other shit can happen here too.
func initiateBoss(target):
	playerSprite = target
	print('Initiated boss with player ' + str(playerSprite.get_rect()))
	bossInitiated = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	light.set_scale(Vector2(1,1) + Vector2(rng.randf_range(-.1,.1), rng.randf_range(-.1,.1)))
	light.energy = 7.05 + rng.randf_range(-1,1)
	
	# have the boss move towards the player 
	if bossInitiated:
		# get the direction vector
		var vec = playerSprite.get_position() - bossSprite.get_position()
		# if player is on left side of the boss
		if vec.x <= 0:
			turn_left()
		# if player is on right side of the boss
		else:
			turn_right()
		
		# if within certain range of player, do an attack
		if vec.length() <= 70 && abs(vec.y) < 20:
			bossSprite.play('attack')
		else:
			# start moving in that direction
			bossSprite.set_position(bossSprite.get_position() + 0.4 * vec.normalized())
			# wait till last animation finished before you start run animation
			if bossSprite.get_frame() == 0:
				bossSprite.play('run')
		
