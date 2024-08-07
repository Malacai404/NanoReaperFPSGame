extends Node3D

var blood_ball = preload("res://blood_orb.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spurt_blood():
	var blood_ball_object = blood_ball.instantiate()
	blood_ball_object.position = position
	get_parent().add_child(blood_ball_object)
func _on_hamster_area_body_entered(body):
	if(body.name == "Player"):
		if(body.is_dashing == true):
			for i in range(25):
				_spurt_blood()
			body.dark_energy_value += 10
			queue_free()
