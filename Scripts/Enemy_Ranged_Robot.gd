extends CharacterBody3D

class_name enemy_ranged_robot

signal enemy_hit

var player_object = null

var health = 5

var speed = 5

var attacking = false
@onready var bullet_prefab = preload("res://Prefabs/enemy_bullet_machine_ranged.tscn")
@onready var nanobot_orb = preload("res://Prefabs/nanobot_orb.tscn")

var ATTACK_RANGE = 0

@export var player_path : NodePath

var dead = false

var state_machine = null

var velocitylocked = false

var player_in_sight: bool
var running_from_player = false

var preloaded_damage = 0

var damage_timer = 0

var currently_shooting = false

var stun_time = 0

@onready var anim_tree = $AnimationTree

@onready var nav_agent = $Enemy_Nav_Agent

func _shoot():
	var bullet = bullet_prefab.instantiate()
	bullet.global_position = $BulletSpawn.global_position
	bullet.player_object = player_object
	get_parent().add_child(bullet)

func _take_delayed_damage(taken_damage):
	if(damage_timer <= 0):
		damage_timer = 0.2
		preloaded_damage += taken_damage

func _start_shooting():
	currently_shooting = true

func _take_damage(taken_damage):
	emit_signal("enemy_hit")
	health -= taken_damage


func _return_direction(loc: Vector3):
	velocitylocked = true
	return position.direction_to(loc)

func _shoot_reset():
	if(!player_in_sight):
		currently_shooting = false
		anim_tree.set("parameters/conditions/shoot", false)
	if(running_from_player):
		currently_shooting = false
		anim_tree.set("parameters/conditions/shoot", false)

func _stun():
	stun_time = 3

func _attack():
	if(_target_in_range()):
		player_object._take_damage()
		player_object.nanobot_count -= 10
	

func _ready():
	player_object = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func _physics_process(delta):
	$RayCast3D.look_at(player_object.position)
	
func _process(_delta):

	player_in_sight = false
	if $RayCast3D.is_colliding():
		if $RayCast3D.get_collider().name == "Player":
			player_in_sight = true
			if(position.distance_to(player_object.position) < 20):
				running_from_player = true
			else:
				running_from_player = false
	if(running_from_player and currently_shooting == false):
		$Armature_002.rotation_degrees = lerp($Armature_002.rotation_degrees, Vector3(90,0,0), 1)
	elif(running_from_player == true or currently_shooting == true):
		$Armature_002.rotation_degrees = lerp($Armature_002.rotation_degrees, Vector3(90,180,0), 1)
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
		nanobot_orb_object.position = Vector3(position.x, position.y - 0.5, position.z)
		nanobot_orb_object.value = 10
		get_parent().add_child(nanobot_orb_object)
		health = 3
		queue_free()
		dead = false
	match  state_machine.get_current_node():
		"fall":
			if(is_on_floor() == false):
				velocity.y -= 9 * _delta
		"walk":
			if(stun_time > 0):
				velocity = lerp(velocity, Vector3(0, velocity.y, 0), 0.5)
				move_and_slide()
				return
			velocitylocked = false
			nav_agent.target_position = player_object.global_transform.origin
			var next_nav_point = nav_agent.get_next_path_position()
			var fakenav = ((next_nav_point - global_transform.origin).normalized() * speed)
			var nav = Vector3(fakenav.x, 0, fakenav.z)
			if(running_from_player):
				velocity = lerp(velocity, -nav, 0.5)
			else:
				velocity = lerp(velocity, nav, 0.5)
			if(running_from_player== false):
				look_at(Vector3(player_object.global_position.x + velocity.x, global_position.y, player_object.global_position.z + velocity.z), Vector3.UP)
			else:
				look_at(Vector3(player_object.global_position.x, global_position.y, player_object.global_position.z), Vector3.UP)
		"shoot":
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
	if(player_in_sight and running_from_player == false):
		anim_tree.set("parameters/conditions/shoot", true)
	if(!player_in_sight or running_from_player == true):
		if(currently_shooting == false):
			anim_tree.set("parameters/conditions/walk", true)
		else:
			anim_tree.set("parameters/conditions/walk", false)
	else:
		anim_tree.set("parameters/conditions/walk", false)
	anim_tree.set("parameters/conditions/falling", !is_on_floor())
	if(!is_on_floor()):
		anim_tree.set("parameters/conditions/walk", false)

	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player_object.global_position) < ATTACK_RANGE


