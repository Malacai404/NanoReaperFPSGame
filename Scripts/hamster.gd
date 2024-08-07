extends CharacterBody3D

var blood_ball = preload("res://Prefabs/blood_orb.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector3(randf_range(-25,25), position.y, randf_range(-25, 25))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	look_at($"../Player".position)
	rotation_degrees = Vector3(0, rotation_degrees.y, 0)

func _spurt_blood():
	var blood_ball_object = blood_ball.instantiate()
	blood_ball_object.position = position
	get_parent().add_child(blood_ball_object)
func _on_hamster_area_body_entered(body):
	if(body.name == "Player"):
		if(body.velocity.x > 8 or body.velocity.z > 8 or body.velocity.x < -8 or body.velocity.z <-8):
			body._start_bounce()
			for i in range(25):
				_spurt_blood()
			body.dark_energy_value += 10
			position = Vector3(randf_range(-25,25), position.y, randf_range(-25, 25))
