extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _die():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in get_overlapping_bodies():
		if i is enemy or i is enemy_soul:
			i._stun()
