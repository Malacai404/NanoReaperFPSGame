extends RigidBody3D

var blood_splat = preload("res://Prefabs/blood.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if(linear_velocity == Vector3.ZERO):
		linear_velocity = Vector3(-1,0,0) * transform.basis


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	linear_velocity.y -= 0.01


func _on_body_entered(body):
	if(body.name == "floor"):
		for i in $blast_radius.get_overlapping_bodies():
			
			if "Enemy_Melee" in i.name:
				i.attacking = false
				i.velocity = i._return_direction(position) * -50
				
			if i.name == "Player":
				i.velocity = i._return_direction(position) * -25
		queue_free()
