extends Node3D

var run_points = []
var farthest = 0
var farthest_point
var player_object
@onready var player_path: NodePath = get_parent().player_path
# Called when the node enters the scene tree for the first time.
func _ready():
	player_object = get_node(player_path)
	run_points = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
