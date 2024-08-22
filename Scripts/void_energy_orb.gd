extends Area3D

var value = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_body_entered(body):
	if body is player:
		if body.void_energy_value < 250:
			body.void_energy_value += 50
			queue_free()
