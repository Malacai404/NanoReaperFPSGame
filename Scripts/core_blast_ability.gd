extends Node3D

@onready var player_object = get_parent()

var core_blast_prefab = preload("res://Prefabs/core_blast.tscn")

func _physics_process(delta):
	if Input.is_action_just_pressed("blast"):
		var core_blast_object =core_blast_prefab.instantiate()
		core_blast_object.global_position = global_position
		core_blast_object.linear_velocity = player_object.velocity
		core_blast_object.rotation_degrees = player_object.rotation_degrees
		player_object.get_parent().add_child(core_blast_object)
