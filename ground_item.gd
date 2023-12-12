extends RigidBody2D

var item_id = 'weapon5' # contains the weapons id
var main_game_node # contains the root of the entire game

# Called when the node enters the scene tree for the first time.
func _ready():
	main_game_node = get_tree().get_root().get_node('Node2D')
	var sprite_data = 'res://assets/anvil.png' # default sprite if one isn't found
	
	if item_id.contains('weapon'):
		sprite_data = main_game_node.searchDocsInList(GlobalVars.lore_data['weapons'], 'id', item_id, 'sprite_data')
	elif item_id.contains('item'):
		sprite_data = main_game_node.searchDocsInList(GlobalVars.lore_data['items'], 'id', item_id, 'sprite_data')
	elif item_id.contains('spell'):
		sprite_data = main_game_node.searchDocsInList(GlobalVars.lore_data['spells'], 'id', item_id, 'sprite_data')
	elif item_id.contains('armor'):
		sprite_data = main_game_node.searchDocsInList(GlobalVars.lore_data['armors'], 'id', item_id, 'sprite_data')
	elif item_id.contains('questitems'):
		sprite_data = main_game_node.searchDocsInList(GlobalVars.lore_data['questitems'], 'id', item_id, 'sprite_data')
	
	get_node("Sprite2D").set_texture(load(sprite_data))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
