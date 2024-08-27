extends Area3D

var scale_factor = 0.1

var blast_power = 1

var already_exploded = []

func _ready():
	scale = Vector3(scale_factor, scale_factor, scale_factor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print(scale)
	for i in get_overlapping_bodies():
		if "enemy" in i.name.to_lower():
			already_exploded.append(i.name)
			i.attacking = false
			var direction =i._return_direction(Vector3(position.x, position.y -50, position.z))
			i.velocity = Vector3(direction.x, direction.y - 1.5, direction.z) * -2 * blast_power
			i._take_delayed_damage(1)
		if i.name == "Player":
			var direction =i._return_direction(Vector3(position.x, position.y, position.z))
			i.velocity += Vector3(direction.x, direction.y, direction.z) * -1 * blast_power
func _kill():
	queue_free()
