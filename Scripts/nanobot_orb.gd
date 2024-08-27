extends Area3D

var value = 100
var is_on_floor = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	is_on_floor = false
	for i in $GroundDetect.get_overlapping_bodies():
		if("floor" in  i.name.to_lower()):
			is_on_floor = true
	if(is_on_floor == false):
		position.y -= delta

func _on_body_entered(body):
	if body is player:
		body.nanobot_count += 10
		queue_free()
