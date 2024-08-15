extends Node3D
var lifetime = 0.3
var alpha = 1.0
var speed = 400

var player_object
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(pos1,pos2):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_transform.origin -= transform.basis.z.normalized() * speed * delta
	scale.z += delta * 5
