extends CharacterBody3D
class_name enemy

signal enemy_hit

var player = null

var health = 5

var speed = 5

var attacking = false

@onready var nanobot_orb = preload("res://Prefabs/nanobot_orb.tscn")

var ATTACK_RANGE = 1.5

@export var player_path : NodePath

var dead = false

var state_machine = null

@onready var anim_tree = $AnimationTree

@onready var nav_agent = $Enemy_Nav_Agent

func _take_damage(taken_damage):
	emit_signal("enemy_hit")
	health -= taken_damage

func _attack_reset():
	if(!_target_in_range()):
		attacking = false

func _attack():
	if(_target_in_range()):
		player.nanobot_count -= 10
	

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
	
func _process(delta):
	if(health <= 0):
		dead = true
	if(dead == true):
		var nanobot_orb_object = nanobot_orb.instantiate()
		nanobot_orb_object.position = Vector3(position.x, position.y - 0.5, position.z)
		nanobot_orb_object.value = 10
		get_parent().add_child(nanobot_orb_object)
		queue_free()
		return
	velocity = Vector3.ZERO
	
	match  state_machine.get_current_node():
		"run":
			nav_agent.target_position = player.global_transform.origin
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !attacking)
	
	if(_target_in_range()):
		attacking = true
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


