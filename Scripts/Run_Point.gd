extends Node3D

var distance 
var player_object
var disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player_object = get_parent().player_object


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in $Area3D.get_overlapping_bodies():
		if i.is_in_group("obstacle"):
			disabled = true
	if(disabled == true):
		$MeshInstance3D.get_surface_override_material().albedo.g = 0.5
	distance = position.direction_to(player_object.position)
	
