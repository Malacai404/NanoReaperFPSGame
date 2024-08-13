extends Area3D

var bullet_speed = 60
var damage = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for i in get_overlapping_bodies():
		if i.name == "Enemy_Melee":
			
			i._take_damage(damage)
			queue_free()
	global_transform.origin -= transform.basis.z.normalized() * bullet_speed * delta
