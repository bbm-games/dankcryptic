extends CanvasLayer

var manafluc = preload("res://materials/manafluc.tres")
var projectile = preload("res://materials/projectile.tres")
var sparks = preload("res://materials/sparks.tres")
var trail = preload("res://materials/trail.tres")

var shield = preload("res://materials/shield.tres")

var particlematerials = [
	manafluc,
	projectile,
	sparks,
	trail
]

var shadermaterials = [
	shield
]

# Called when the node enters the scene tree for the first time.
func _ready():
	for material in particlematerials:
		var material_instance = GPUParticles2D.new()
		material_instance.set_process_material(material)
		material_instance.set_one_shot(true)
		material_instance.set_modulate(Color(1,1,1,0))
		material_instance.set_emitting(true)
		self.add_child(material_instance)

	for material in shadermaterials:
		var material_instance = ColorRect.new()
		material_instance.set_material(material)
		# for some reason this next line doesn't actually get the shader to go
		#material_instance.set_modulate(Color(1,1,1,0))
		self.add_child(material_instance)
		
		
		
		
		
