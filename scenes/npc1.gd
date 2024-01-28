extends CharacterBody2D

var chatting
var etime
var chatIcon
var boundary
var viscinity
var chatPopup
var chatSound
var supriseSound
var chatPortrait
var chatIconAnimationPlayer
var endConvoIndex
var convoOptions
var initialConvoStateID = "ID 0"
var is_attackable = false

func _ready():
	etime = 0
	chatting = false
	viscinity = false
	
	# boundary for detecting player in viscinity
	boundary = get_node("npcBoundary")
	
	# grab the chat popup from the main game HUD for manipulation purposes
	chatPopup = get_tree().get_root().get_node("Node2D/HUDLayer/chatPopup")
	chatPopup.hide()
	
	# get the sounds
	supriseSound = get_node("surpriseSound")
	chatSound = get_node("chatSound")
	
	# set the chat icon animation above npc's head
	chatIcon = get_node('chatIcon')
	chatIcon.hide()
	chatIconAnimationPlayer = get_node("chatIconAnimationPlayer")
	chatIconAnimationPlayer.play("bounce")
	
	# set the npc portrait for chatting
	var chatPortraitTexture = preload("res://assets/griffith.png")
	chatPortrait = chatPopup.get_node("%chatPortrait")
	chatPortrait.set_texture(chatPortraitTexture)
	
	# set the npc name for chatting
	chatPopup.get_node("%npcName").set_text("Big Scary Knight")
	
	# TODO: make the prompting smarter
	#chatPopup.get_node("%prompt").set_text("Fuck you. Get out of my sight.\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Integer sodales hendrerit diam, nec aliquam lorem rutrum ac. Suspendisse potenti. Mauris lacus sem, tincidunt et mattis consectetur, maximus at mauris. Duis metus lorem, vehicula sit amet tristique sit amet, facilisis et sapien. Nam tempus bibendum auctor. Pellentesque maximus nulla a tellus ultrices placerat. Curabitur varius dui vulputate tincidunt pellentesque. Aenean tellus nisl, bibendum nec lacus eu, mollis molestie erat.")
	
	# get convoOptions node
	convoOptions = chatPopup.get_node("%convoOptions")
	
	# initialize the first prompt
	setConvoState(initialConvoStateID)

	# initiate the item_clicked loop
	convoOptions.connect("item_clicked", convoOptionsItemClicked)
	
func setConvoState(id):
	convoOptions.clear()
	# TODO: get the prompt based on id
	chatPopup.get_node("%prompt").set_text("Fuck you. Get out of my sight. " + id)
	convoOptions.add_item("Option 1")
	convoOptions.add_item("Option 2")
	convoOptions.add_item(id)
	# Set up the default convo exit option
	convoOptions.add_item("End conversation.")
	
	# turn off annoying item tooltips
	for i in range(0,convoOptions.get_item_count()):
		convoOptions.set_item_tooltip_enabled(i,false)

func convoOptionsItemClicked(index, _at_position, _mouse_button_index):
	# index of the end convo option is always the last one
	endConvoIndex = convoOptions.get_item_count() - 1 
	if index == endConvoIndex:
		# turn chatting off and restart the convo from the begning
		setConvoState(initialConvoStateID)
		chatting = false
	else:
		# look up where the selected id will take us
		setConvoState("ID 1")
	
#func _process(delta):
#	pass
	
func _physics_process(delta):
	etime = etime + delta
	if not viscinity:
		chatPopup.hide()
		chatting = false
		# make character move back and forth
		if int(etime) % 5:
			move_and_collide(Vector2(-1,0) * 0.4)
		else:
			move_and_collide(Vector2(1,0) * 0.4)
	# if object has collided
	else:
	# listen to see if the player wants to chat
		if chatting:
			chatIcon.hide()
			chatPopup.show()
			chatPopup.get_node("%convoOptions").grab_focus()
		else:
			chatIcon.show()
			chatPopup.hide()
			
func _input(event):
	#print(event.as_text())
	if event.is_action_pressed("chat") and viscinity:
		# start chatting if they're not chatting
		if chatting == false:
			chatting = true
			chatSound.play()
		else:
			# if they are chatting, then advance in the chat by selecting the focused thing
			pass
		
# functions to show chat icon when player is in viscinity
func _on_npc_boundary_body_entered(_body):
	chatIcon.show()
	viscinity = true
	# play suprise audio
	supriseSound.play()

func _on_npc_boundary_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):
	chatIcon.hide()
	viscinity = false
