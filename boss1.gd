extends Node2D
var bossBody
var bossSprite
var light
var rng
var bossInitiated = false
var playerBody
var tileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	tileMap = get_node('TileMap')
	
	bossBody = get_node("boss")
	bossSprite = bossBody.get_node('bossSprite')
	
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
	playerBody = target
	print('Initiated boss with player')
	bossInitiated = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# have the boss move towards the player 
	if bossInitiated:
		# get the direction vector
		var vec = playerBody.get_position() - bossBody.get_position()
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
			bossBody.move_and_collide(0.4 * vec.normalized())
			# wait till last animation finished before you start run animation
			if bossSprite.get_frame() == 0:
				bossSprite.play('run')
		
