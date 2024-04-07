extends Area2D

var des_vel: Vector2
var vel = Vector2(0,0)
var rng 

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	get_node('goldSprite').set_frame(randi_range(0,5))
	get_node('goldSprite').play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bodies = get_node('detection').get_overlapping_bodies();
	if bodies:
		for body in bodies:
			if body.is_player:
				# animate coin going to player
				des_vel = (body.position - self.get_position()).normalized() * 120
				var steering = (des_vel - vel) / 1
				vel += steering
				self.set_position(self.get_position() + vel * delta)

func _on_body_entered(_body):
	#print(get_tree().get_root().get_node('Node2D'))
	get_tree().get_root().get_node('Node2D').hit_coin()
	queue_free()
