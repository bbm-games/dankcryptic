extends RigidBody2D
var main_game_node
var rng
var is_chest = true
var is_open = false
var has_item = true

# the items that the chest will return
var item_ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	rng = RandomNumberGenerator.new() 
	for i in range(rng.randi_range(1,5)):
		item_ids.append(GlobalVars.choose_random_from_list(GlobalVars.lore_data['armors'] + GlobalVars.lore_data['weapons'] + GlobalVars.lore_data['spells'])['id'])

func open_chest():
	if not is_open:
		get_node("AnimationPlayer").play('glowing')
		get_node('openSound').play()
		is_open = true
	
# TODO: make this function take in a discovery level to deermine which items to give
func take_item():
	if has_item:
		get_node("AnimationPlayer").play('open')
		# give the player some coins too
		main_game_node.give_coins(rng.randi_range(0,60))
		has_item = false
		return item_ids
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
