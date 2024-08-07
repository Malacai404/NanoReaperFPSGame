extends RigidBody3D

var blood_splat = preload("res://Prefabs/blood.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity.x = randf_range(-7, 7)
	linear_velocity.z = randf_range(-7, 7)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if(body.name == "floor"):
		var blood_object = blood_splat.instantiate()
		blood_object.position= Vector3(position.x, position.y -0.15, position.z)
		blood_object.rotation_degrees.y = randf_range(-90,90)
		get_parent().add_child(blood_object)
		queue_free()
