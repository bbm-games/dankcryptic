extends RigidBody2D

var item_id = 'weapon5' # this is the default item id
var is_ground_item = true
var main_game_node # contains the root of the entire game
var outline # outline shader

# Called when the node enters the scene tree for the first time.
func _ready():
	outline = preload("res://itemoutline.gdshader")
	main_game_node = get_tree().get_root().get_node('Node2D')

func load_item(item_id_given):
	
	item_id = item_id_given
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
	
func _on_mouse_entered():
	get_node("Sprite2D").material.shader = outline

func _on_mouse_exited():
	get_node("Sprite2D").material.shader = null
