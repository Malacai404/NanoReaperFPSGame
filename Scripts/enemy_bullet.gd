extends Area3D

var bullet_speed = 50

var player_object: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	look_at(player_object.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in get_overlapping_bodies():
		if i.name == "Player":
			i.nanobot_count -= 5
			queue_free()
	global_transform.origin -= transform.basis.z.normalized() * bullet_speed * delta
