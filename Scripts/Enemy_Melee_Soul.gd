extends CharacterBody3D
class_name enemy_soul

signal enemy_hit

var player_object = null

var health = 5

var is_moving = true

var movement_length = 2

var speed = 10

var attacking = false

@onready var nanobot_orb = preload("res://Prefabs/void_energy_orb.tscn")

var ATTACK_RANGE = 3

@export var player_path : NodePath

var dead = false

var state_machine = null

var velocitylocked = false

var preloaded_damage = 0

var damage_timer = 0

@onready var anim_tree = $AnimationTree

@onready var nav_agent = $Enemy_Nav_Agent

func _take_delayed_damage(taken_damage):
	if(damage_timer <= 0):
		damage_timer = 0.2
		preloaded_damage += taken_damage

func _take_damage(taken_damage):
	print("Soul hit")
	health -= taken_damage


func _return_direction(loc: Vector3):
	velocitylocked = true
	return position.direction_to(loc)

func _attack_reset():
	print("Reset")
	if(!_target_in_range()):
		
		attacking = false

func _attack():
	movement_length = 1
	if(_target_in_range()):
		player_object.nanobot_count -= 10
	

func _ready():
	movement_length = randf_range(1.3,3)
	player_object = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
	
func _process(_delta):
	
	if(is_moving == false):
		movement_length += _delta
		if(movement_length >= 1):
			is_moving = true
	else:
		movement_length -= _delta
		if(movement_length <= 0):
			is_moving = false
	
	if(damage_timer >= 0):
		damage_timer -= _delta
	else:
		health -= preloaded_damage
		preloaded_damage = 0
	if(health <= 0):
		dead = true
	if(dead == true):
		var nanobot_orb_object = nanobot_orb.instantiate()
		nanobot_orb_object.position = Vector3(position.x, position.y - 0.5, position.z)
		nanobot_orb_object.value = 10
		get_parent().add_child(nanobot_orb_object)
		health = 3
		position = Vector3(randf_range(-25,25), 0.2, randf_range(-25,25))
		dead = false
	match  state_machine.get_current_node():
		"run":
			if(is_on_floor() and is_moving):
				velocitylocked = false
				nav_agent.target_position = player_object.global_transform.origin
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = lerp(velocity, ((next_nav_point - global_transform.origin).normalized() * speed), 0.5)
				look_at(Vector3(player_object.global_position.x + velocity.x, global_position.y, player_object.global_position.z + velocity.z), Vector3.UP)
			elif(is_moving == false):
				velocity = lerp(velocity, Vector3.ZERO, 0.5)
				look_at(Vector3(player_object.global_position.x + velocity.x, global_position.y, player_object.global_position.z + velocity.z), Vector3.UP)
		"attack":
			if(velocitylocked == false):
				velocity = lerp(velocity, Vector3.ZERO, 0.5)
			else:
				attacking = false
			look_at(Vector3(player_object.global_position.x, global_position.y, player_object.global_position.z), Vector3.UP)
	velocity.y -= _delta * 9.8
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !attacking)
	
	if(_target_in_range()):
		attacking = true
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player_object.global_position) < ATTACK_RANGE

