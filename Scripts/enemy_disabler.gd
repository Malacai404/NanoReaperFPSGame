extends Area3D

@export var enemy_path: NodePath
var enemy_object

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_object = get_node(enemy_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enemy_object.disable = true


func _on_body_entered(body):
	enemy_object.disable =false
