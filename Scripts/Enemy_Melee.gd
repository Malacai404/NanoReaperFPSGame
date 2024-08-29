extends CharacterBody3D
class_name enemy

signal enemy_hit

var player_object = null

var health = 5

var speed = 5

var attacking = false

@onready var nanobot_orb = preload("res://Prefabs/nanobot_orb.tscn")

var ATTACK_RANGE = 1.5

@export var player_path : NodePath

var disable = false

var dead = false

var state_machine = null

var velocitylocked = false

var preloaded_damage = 0

var damage_timer = 0


var stun_time = 0

@onready var anim_tree = $AnimationTree

@onready var nav_agent = $Enemy_Nav_Agent

func _take_delayed_damage(taken_damage):
	if(damage_timer <= 0):
		damage_timer = 0.2
		preloaded_damage += taken_damage

func _take_damage(taken_damage):
	emit_signal("enemy_hit")
	health -= taken_damage


func _return_direction(loc: Vector3):
	velocitylocked = true
	return position.direction_to(loc)

func _attack_reset():
	if(!_target_in_range()):
		attacking = false

func _stun():
	stun_time = 3

func _attack():
	if(_target_in_range()):
		player_object._take_damage()
		player_object.nanobot_count -= 10
	

func _ready():
	player_object = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
	
func _process(_delta):
	stun_time -= _delta
	for i in $Enemy_Checker.get_overlapping_bodies():
		if i is enemy or i is enemy_soul:
			if(i.name != self.name):
				var veloc = randf_range(-2,2)
				velocity.x += veloc
	if(damage_timer >= 0):
		damage_timer -= _delta
	else:
		health -= preloaded_damage
		preloaded_damage = 0
	if(health <= 0):
		dead = true
	if(dead == true):
		var nanobot_orb_object = nanobot_orb.instantiate()
		nanobot_orb_object.position = Vector3(position.x, position.y + 0.5, position.z)
		nanobot_orb_object.value = 10
		get_parent().add_child(nanobot_orb_object)
		health = 3
		queue_free()
		dead = false
	match  state_machine.get_current_node():
		"falling":
			if(is_on_floor() == false):
				velocity.y -= 9 * _delta
		"run":
			if(stun_time > 0):
				velocity = lerp(velocity, Vector3(0, velocity.y, 0), 0.5)
				move_and_slide()
				return
			velocitylocked = false
			nav_agent.target_position = player_object.global_transform.origin
			var next_nav_point = nav_agent.get_next_path_position()
			var fakenav = ((next_nav_point - global_transform.origin).normalized() * speed)
			var nav = Vector3(fakenav.x, 0, fakenav.z)
			velocity = lerp(velocity, nav, 0.5)
			look_at(Vector3(player_object.global_position.x + velocity.x, global_position.y, player_object.global_position.z + velocity.z), Vector3.UP)
		"attack":
			if(stun_time > 0):
				velocity = lerp(velocity, Vector3(0, velocity.y, 0), 0.5)
				move_and_slide()
				return
			if(velocitylocked == false):
				velocity = lerp(velocity, Vector3.ZERO, 0.5)
			else:
				attacking = false
			look_at(Vector3(player_object.global_position.x, global_position.y, player_object.global_position.z), Vector3.UP)
	if(is_on_floor() == false):
		velocity.y -= 9 * _delta
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !attacking)
	anim_tree.set("parameters/conditions/falling", !is_on_floor())
	if(!is_on_floor()):
		anim_tree.set("parameters/conditions/run", false)
	if(_target_in_range()):
		attacking = true
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player_object.global_position) < ATTACK_RANGE


