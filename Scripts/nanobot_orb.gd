extends Area3D

var value = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_body_entered(body):
	if body is player:
		body.nanobot_count += value
		queue_free()
