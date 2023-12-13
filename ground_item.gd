extends RigidBody2D

var item_id = 'weapon5' # this is the default item id
var is_ground_item = true
var is_attackable = false
var main_game_node # contains the root of the entire game
#var outline # outline shader
#signal highlight_item
#signal unhighlight_item

# Called when the node enters the scene tree for the first time.
func _ready():
	#highlight_item.connect(highlight.bind(get_node("Sprite2D")))
	#unhighlight_item.connect(unhighlight.bind(get_node("Sprite2D")))
	#outline = preload("res://itemoutline.gdshader")
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

'''
func highlight(item_sprite):
	if item_sprite == get_node('Sprite2D'):
		item_sprite.material.shader = outline

func unhighlight(item_sprite):
	if item_sprite == get_node('Sprite2D'):
		item_sprite.material.shader = null
'''
func _on_mouse_entered():
	#emit_signal('highlight_item')
	get_node("Sprite2D").material.set_shader_parameter('width',1)
	#main_game_node.chatBoxAppend(item_id)
	pass

func _on_mouse_exited():
	#emit_signal('unhighlight_item')
	get_node("Sprite2D").material.set_shader_parameter('width',0)
	pass
