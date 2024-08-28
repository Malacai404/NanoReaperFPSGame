extends Node3D

var run_points = []
var closest
var player_object
@onready var player_path: NodePath = get_parent().player_path
# Called when the node enters the scene tree for the first time.
func _ready():
	player_object = get_node(player_path)
	run_points = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in run_points:
		var hitting_wall = false
		for c in i.get_child(0).get_overlapping_bodies():
			if "enemy" not in c.name:
				if "player" not in c.name:
					hitting_wall = true
		
		print(i.position.distance_to(player_object.positioon))
		
		if(hitting_wall == true):
			pass
