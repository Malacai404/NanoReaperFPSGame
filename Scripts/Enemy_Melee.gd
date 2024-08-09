extends CharacterBody3D


var player = null

var speed = 5

var attacking = false

var ATTACK_RANGE = 2

@export var player_path : NodePath

var dead

var state_machine = null

@onready var anim_tree = $AnimationTree

@onready var nav_agent = $Enemy_Nav_Agent

func _attack_reset():
	attacking = false

func _attack():
	if(_target_in_range()):
		player.nanobot_count -= 10
	

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
	
func _process(delta):
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


