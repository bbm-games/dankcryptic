extends CharacterBody2D

var chatting
var etime
var chatIcon
var boundary
var viscinity
var chatPopup

func _ready():
	etime = 0
	chatting = false
	viscinity = false
	chatIcon = get_node('chatIcon')
	chatIcon.hide()
	boundary = get_node("npcBoundary")
	chatPopup = get_tree().get_root().get_node("Node2D/HUDLayer/chatPopup")
	chatPopup.hide()
	
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
		else:
			chatIcon.show()
			chatPopup.hide()
			
func _input(event):
	#print(event.as_text())
	if event.is_action_pressed("chat"):
		chatting = true
		
# functions to show chat icon when player is in viscinity
func _on_npc_boundary_body_entered(body):
	chatIcon.show()
	viscinity = true

func _on_npc_boundary_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	chatIcon.hide()
	viscinity = false
