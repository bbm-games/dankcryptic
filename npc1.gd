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
	chatPopup.get_node("%prompt").set_text("Fuck you. Get out of my sight.")

	# TODO: make custom response options
	
	# program the end convo button
	chatPopup.get_node("%endConvoButton").connect("pressed", onEndConvoButtonPressed)
	
func onEndConvoButtonPressed():
	print("exiting chat")
	chatting = false

func _process(delta):
	pass
	
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
			chatPopup.get_node("%endConvoButton").grab_focus()
		else:
			chatIcon.show()
			chatPopup.hide()
			
func _input(event):
	#print(event.as_text())
	if event.is_action_pressed("chat") and viscinity:
		chatting = true
		chatSound.play()
		
# functions to show chat icon when player is in viscinity
func _on_npc_boundary_body_entered(body):
	chatIcon.show()
	viscinity = true
	# play suprise audio
	supriseSound.play()

func _on_npc_boundary_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	chatIcon.hide()
	viscinity = false
